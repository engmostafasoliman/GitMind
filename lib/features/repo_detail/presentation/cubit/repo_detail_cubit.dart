import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/api_result.dart';
import '../../../repo_list/domain/usecases/generate_summary_usecase.dart';
import '../../../repo_list/domain/usecases/get_repo_detail_usecase.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import 'repo_detail_state.dart';

class RepoDetailCubit extends Cubit<RepoDetailState> {
  final GetRepoDetailUseCase _getDetail;
  final GenerateSummaryUseCase _generateSummary;
  final SettingsRepository _settingsRepo;
  final AnalyticsService _analytics;
  Timer? _rateLimitTimer;

  static const _rateLimitRetrySeconds = 15;

  RepoDetailCubit(this._getDetail, this._generateSummary, this._settingsRepo,
      {AnalyticsService? analytics})
      : _analytics = analytics ?? getIt<AnalyticsService>(),
        super(const RepoDetailInitial());

  Future<void> load(String repoId) async {
    emit(const RepoDetailLoading());
    final result = await _getDetail(repoId);
    switch (result) {
      case ApiSuccess(:final data):
        _analytics.logRepoViewed(data.id, data.name);
        emit(RepoDetailLoaded(data));
        if (!data.summarized) {
          final settings = await _settingsRepo.load();
          if (settings.autoSummarize) await generateSummary();
        }
      case ApiFailure(:final message):
        emit(RepoDetailError(message));
      case ApiRateLimit():
        emit(const RepoDetailError('Service temporarily unavailable. Please try again.'));
    }
  }

  Future<void> generateSummary({bool force = false}) async {
    final current = state;
    final repo = _repoFrom(current);
    if (repo == null) return;
    _cancelRateLimit();
    emit(RepoDetailGenerating(repo));
    final result = await _generateSummary(repo.id, force: force);
    switch (result) {
      case ApiSuccess(:final data):
        _analytics.logSummaryGenerated(repo.id, regenerated: force);
        emit(RepoDetailLoaded(repo.withSummary(data)));
      case ApiRateLimit():
        _analytics.logSummaryRateLimit(repo.id);
        _startRateLimitCountdown(repo, force: force);
      case ApiFailure(:final message):
        emit(RepoDetailError(message));
    }
  }

  Future<void> regenerateSummary() => generateSummary(force: true);

  void _startRateLimitCountdown(RepoEntity repo, {bool force = false}) {
    _cancelRateLimit();
    emit(RepoDetailRateLimit(repo, _rateLimitRetrySeconds));
    var remaining = _rateLimitRetrySeconds;
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (isClosed) { t.cancel(); return; }
      remaining--;
      if (remaining <= 0) {
        t.cancel();
        await generateSummary(force: force);
      } else {
        emit(RepoDetailRateLimit(repo, remaining));
      }
    });
  }

  void _cancelRateLimit() {
    _rateLimitTimer?.cancel();
    _rateLimitTimer = null;
  }

  RepoEntity? _repoFrom(RepoDetailState state) => switch (state) {
    RepoDetailLoaded(:final repo) => repo,
    RepoDetailGenerating(:final repo) => repo,
    RepoDetailRateLimit(:final repo) => repo,
    _ => null,
  };

  @override
  Future<void> close() {
    _cancelRateLimit();
    return super.close();
  }
}
