import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../../features/settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/repo_summary_entity.dart';
import '../models/repo_model.dart';
import '../services/gemini_repo_summary_service.dart';
import 'repo_data_source.dart';
import 'repo_summary_db.dart';

class GitHubRepoDataSource implements RepoDataSource {
  final FlutterSecureStorage _storage;
  final GeminiRepoSummaryService _gemini;
  final RepoSummaryDb _db;
  final SettingsRepository _settingsRepo;
  List<RepoModel>? _cache;
  final Map<String, RepoSummaryEntity> _summaryCache = {};

  GitHubRepoDataSource({
    FlutterSecureStorage? storage,
    required GeminiRepoSummaryService gemini,
    required RepoSummaryDb db,
    required SettingsRepository settingsRepo,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _gemini = gemini,
        _db = db,
        _settingsRepo = settingsRepo;

  Future<String> get _token async {
    final token = await _storage.read(key: 'github_access_token');
    if (token == null) throw Exception('Not authenticated');
    return token;
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
      };

  @override
  Future<List<RepoModel>> getRepos() async {
    final token = await _token;
    final response = await http.get(
      Uri.parse(
          'https://api.github.com/user/repos?per_page=100&sort=updated&type=all'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('GitHub API error: ${response.statusCode}');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    final repos = list
        .map((json) => RepoModel.fromGitHub(json as Map<String, dynamic>))
        .toList();

    // Load all persisted summaries in one query and merge into repo list
    final persisted = await _db.getAll();
    final merged = repos.map((r) {
      final saved = persisted[r.id];
      if (saved == null) return r;
      _summaryCache[r.id] = saved;
      return RepoModel(
        id: r.id,
        name: r.name,
        owner: r.owner,
        description: r.description,
        language: r.language,
        stars: r.stars,
        updatedAgo: r.updatedAgo,
        license: r.license,
        lastCommit: r.lastCommit,
        summarized: true,
        summary: saved,
      );
    }).toList();

    _cache = merged;
    return merged;
  }

  @override
  Future<RepoModel> getRepoById(String id) async {
    if (_cache != null) {
      final cached = _cache!.where((r) => r.id == id).firstOrNull;
      if (cached != null) return cached;
    }

    final token = await _token;
    final response = await http.get(
      Uri.parse('https://api.github.com/repositories/$id'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Repository not found');
    }

    return RepoModel.fromGitHub(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<RepoSummaryEntity> generateSummary(String repoId,
      {bool force = false}) async {
    final settings = await _settingsRepo.load();
    final effectiveForce = force || !settings.cacheResults;

    if (!effectiveForce) {
      // 1. In-memory cache
      if (_summaryCache.containsKey(repoId)) return _summaryCache[repoId]!;

      // 2. Persistent DB cache
      final saved = await _db.get(repoId);
      if (saved != null) {
        _summaryCache[repoId] = saved;
        _applyToCache(repoId, saved);
        return saved;
      }
    } else {
      _summaryCache.remove(repoId);
    }

    // 3. Call Gemini
    final repo = await getRepoById(repoId);
    final token = await _token;

    final results = await Future.wait([
      http.get(
        Uri.parse(
            'https://api.github.com/repos/${repo.owner}/${repo.name}/languages'),
        headers: _headers(token),
      ),
      http.get(
        Uri.parse(
            'https://api.github.com/repos/${repo.owner}/${repo.name}/readme'),
        headers: _headers(token),
      ),
    ]);

    final langResponse = results[0];
    final readmeResponse = results[1];

    final languages = langResponse.statusCode == 200
        ? (jsonDecode(langResponse.body) as Map<String, dynamic>)
            .cast<String, int>()
        : <String, int>{};

    String readme = '';
    if (readmeResponse.statusCode == 200) {
      final readmeJson =
          jsonDecode(readmeResponse.body) as Map<String, dynamic>;
      final encoded = readmeJson['content'] as String? ?? '';
      readme = utf8.decode(base64.decode(encoded.replaceAll('\n', '')));
    }

    final summary = await _gemini.summarize(
      name: repo.name,
      owner: repo.owner,
      description: repo.description,
      language: repo.language,
      languages: languages,
      stars: repo.stars,
      readme: readme,
      model: settings.geminiModel,
    );

    // Persist and cache
    await _db.save(repoId, summary);
    _summaryCache[repoId] = summary;
    _applyToCache(repoId, summary);

    return summary;
  }

  @override
  Future<void> clearSummaries() async {
    _summaryCache.clear();
    await _db.deleteAll();
    if (_cache != null) {
      _cache = _cache!.map((r) => RepoModel(
            id: r.id,
            name: r.name,
            owner: r.owner,
            description: r.description,
            language: r.language,
            stars: r.stars,
            updatedAgo: r.updatedAgo,
            license: r.license,
            lastCommit: r.lastCommit,
            summarized: false,
            summary: null,
          )).toList();
    }
  }

  void _applyToCache(String repoId, RepoSummaryEntity summary) {
    if (_cache == null) return;
    _cache = _cache!.map((r) {
      if (r.id != repoId) return r;
      return RepoModel(
        id: r.id,
        name: r.name,
        owner: r.owner,
        description: r.description,
        language: r.language,
        stars: r.stars,
        updatedAgo: r.updatedAgo,
        license: r.license,
        lastCommit: r.lastCommit,
        summarized: true,
        summary: summary,
      );
    }).toList();
  }
}
