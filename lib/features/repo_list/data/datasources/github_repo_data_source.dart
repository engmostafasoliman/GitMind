import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/repo_summary_entity.dart';
import '../models/repo_model.dart';
import 'github_repo_http_source.dart';
import 'repo_data_source.dart';
import 'repo_summary_data_source.dart';

class GitHubRepoDataSource implements RepoDataSource {
  final FlutterSecureStorage _storage;
  final GitHubRepoHttpSource _http;
  final RepoSummaryDataSource _summary;

  GitHubRepoDataSource({
    FlutterSecureStorage? storage,
    required GitHubRepoHttpSource http,
    required RepoSummaryDataSource summary,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _http = http,
        _summary = summary;

  Future<String> get _token async {
    final token = await _storage.read(key: 'github_access_token');
    if (token == null) throw Exception('Not authenticated');
    return token;
  }

  @override
  Future<List<RepoModel>> getRepos() async {
    final token = await _token;
    final repos = await _http.getRepos(token);
    return _summary.mergeWithDb(repos);
  }

  @override
  Future<RepoModel> getRepoById(String id) async {
    final cached = _summary.cachedRepoById(id);
    if (cached != null) return cached;
    final token = await _token;
    return _http.getRepoById(token, id);
  }

  @override
  Future<RepoSummaryEntity> generateSummary(String repoId,
      {bool force = false}) async {
    final cached = await _summary.getCached(repoId, force: force);
    if (cached != null) return cached;

    final token = await _token;
    final repo = await getRepoById(repoId);

    final results = await Future.wait([
      _http.getLanguages(token, repo.owner, repo.name),
      _http.getReadme(token, repo.owner, repo.name),
    ]);

    return _summary.fetchFromGemini(
      repo: repo,
      languages: results[0] as Map<String, int>,
      readme: results[1] as String,
    );
  }

  @override
  Future<void> clearSummaries() => _summary.clearSummaries();
}
