import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/repo_summary_entity.dart';
import '../models/repo_model.dart';
import 'repo_data_source.dart';

class GitHubRepoDataSource implements RepoDataSource {
  final FlutterSecureStorage _storage;
  List<RepoModel>? _cache;

  GitHubRepoDataSource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

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

    _cache = repos;
    return repos;
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
  Future<RepoSummaryEntity> generateSummary(String repoId) {
    // Gemini integration — Phase 3
    throw UnimplementedError('AI summary coming in Phase 3');
  }
}
