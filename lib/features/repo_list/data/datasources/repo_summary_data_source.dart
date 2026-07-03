import '../../../../core/error/app_exception.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../domain/entities/repo_summary_entity.dart';
import '../models/repo_model.dart';
import '../services/gemini_repo_summary_service.dart';
import 'repo_summary_db.dart';

class RepoSummaryDataSource {
  final GeminiRepoSummaryService _gemini;
  final RepoSummaryDb _db;
  final SettingsRepository _settingsRepo;

  List<RepoModel>? _repoListCache;
  final Map<String, RepoSummaryEntity> _summaryCache = {};
  final Map<String, DateTime> _lastGeminiCall = {};

  static const _throttleDuration = Duration(seconds: 10);

  RepoSummaryDataSource({
    required GeminiRepoSummaryService gemini,
    required RepoSummaryDb db,
    required SettingsRepository settingsRepo,
  })  : _gemini = gemini,
        _db = db,
        _settingsRepo = settingsRepo;

  /// Merges DB-persisted summaries into a freshly-fetched repo list,
  /// updates the in-memory repo cache, and returns the merged list.
  Future<List<RepoModel>> mergeWithDb(List<RepoModel> repos) async {
    final persisted = await _db.getAll();
    final merged = repos.map((r) {
      final saved = persisted[r.id];
      if (saved == null) return r;
      _summaryCache[r.id] = saved;
      return _withSummary(r, saved);
    }).toList();
    _repoListCache = merged;
    return merged;
  }

  RepoModel? cachedRepoById(String id) =>
      _repoListCache?.where((r) => r.id == id).firstOrNull;

  /// Returns a cached summary (memory → DB) when available and not bypassed
  /// by `force` or the `cacheResults` setting. Returns null if a fresh
  /// Gemini call should be made.
  Future<RepoSummaryEntity?> getCached(String repoId,
      {required bool force}) async {
    final settings = await _settingsRepo.load();
    final effectiveForce = force || !settings.cacheResults;
    if (effectiveForce) {
      _summaryCache.remove(repoId);
      return null;
    }
    if (_summaryCache.containsKey(repoId)) return _summaryCache[repoId];
    final saved = await _db.get(repoId);
    if (saved != null) {
      _summaryCache[repoId] = saved;
      _applyToRepoCache(repoId, saved);
    }
    return saved;
  }

  /// Calls Gemini with pre-fetched repo data. Enforces the per-repo throttle
  /// and persists the result to DB + memory caches.
  Future<RepoSummaryEntity> fetchFromGemini({
    required RepoModel repo,
    required Map<String, int> languages,
    required String readme,
  }) async {
    final lastCall = _lastGeminiCall[repo.id];
    if (lastCall != null &&
        DateTime.now().difference(lastCall) < _throttleDuration) {
      throw const RateLimitException();
    }
    _lastGeminiCall[repo.id] = DateTime.now();

    final settings = await _settingsRepo.load();
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

    await _db.save(repo.id, summary);
    _summaryCache[repo.id] = summary;
    _applyToRepoCache(repo.id, summary);
    return summary;
  }

  void _applyToRepoCache(String repoId, RepoSummaryEntity summary) {
    if (_repoListCache == null) return;
    _repoListCache = _repoListCache!
        .map((r) => r.id == repoId ? _withSummary(r, summary) : r)
        .toList();
  }

  RepoModel _withSummary(RepoModel r, RepoSummaryEntity summary) => RepoModel(
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

  Future<void> clearSummaries() async {
    _summaryCache.clear();
    await _db.deleteAll();
    if (_repoListCache != null) {
      _repoListCache = _repoListCache!
          .map((r) => RepoModel(
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
              ))
          .toList();
    }
  }
}
