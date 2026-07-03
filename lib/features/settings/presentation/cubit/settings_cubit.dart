import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../repo_list/domain/usecases/clear_summaries_usecase.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;
  final ThemeCubit _themeCubit;
  final ClearSummariesUseCase _clearSummaries;
  final AnalyticsService _analytics;

  SettingsCubit(this._repo, this._themeCubit, this._clearSummaries,
      {AnalyticsService? analytics})
      : _analytics = analytics ?? getIt<AnalyticsService>(),
        super(const SettingsLoading());

  Future<void> load() async {
    final settings = await _repo.load();
    AppColors.setAccentId(settings.accentColor);
    _themeCubit.setAccent(settings.accentColor);
    emit(SettingsLoaded(settings));
  }

  SettingsEntity get _current =>
      state is SettingsLoaded ? (state as SettingsLoaded).settings : SettingsEntity.defaults;

  Future<void> _update(SettingsEntity updated) async {
    await _repo.save(updated);
    emit(SettingsLoaded(updated));
  }

  Future<void> setGeminiModel(String model) async {
    _analytics.logModelChanged(model);
    return _update(_current.copyWith(geminiModel: model));
  }

  Future<void> setAutoSummarize(bool v) => _update(_current.copyWith(autoSummarize: v));

  Future<void> setCacheResults(bool v) => _update(_current.copyWith(cacheResults: v));

  Future<void> setMinConfidence(String v) => _update(_current.copyWith(minConfidence: v));

  Future<void> setAccentColor(String id) async {
    AppColors.setAccentId(id);
    _themeCubit.setAccent(id);
    await _update(_current.copyWith(accentColor: id));
  }

  Future<void> setDensity(String v) => _update(_current.copyWith(density: v));

  Future<void> setEmailDigest(bool v) => _update(_current.copyWith(emailDigest: v));

  Future<void> setNotifyOnDone(bool v) => _update(_current.copyWith(notifyOnDone: v));

  Future<void> clearSummaries() => _clearSummaries();
}
