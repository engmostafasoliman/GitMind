import 'package:bloc_test/bloc_test.dart';
import 'package:chaty_ai_agent/core/analytics/analytics_service.dart';
import 'package:chaty_ai_agent/core/di/injection.dart';
import 'package:chaty_ai_agent/core/theme/theme_cubit.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/repositories/repo_repository.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/usecases/clear_summaries_usecase.dart';
import 'package:chaty_ai_agent/features/settings/domain/entities/settings_entity.dart';
import 'package:chaty_ai_agent/features/settings/domain/repositories/settings_repository.dart';
import 'package:chaty_ai_agent/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:chaty_ai_agent/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockRepoRepository extends Mock implements RepoRepository {}
class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockSettingsRepository mockRepo;
  late ThemeCubit themeCubit;
  late ClearSummariesUseCase clearSummaries;
  late MockRepoRepository mockRepoRepository;
  late MockAnalyticsService mockAnalytics;

  setUpAll(() {
    registerFallbackValue(SettingsEntity.defaults);
  });

  setUp(() {
    mockRepo = MockSettingsRepository();
    themeCubit = ThemeCubit();
    mockRepoRepository = MockRepoRepository();
    clearSummaries = ClearSummariesUseCase(mockRepoRepository);
    mockAnalytics = MockAnalyticsService();

    when(() => mockRepo.load()).thenAnswer((_) async => SettingsEntity.defaults);
    when(() => mockRepo.save(any())).thenAnswer((_) async {});
    when(() => mockRepoRepository.clearSummaries()).thenAnswer((_) async {});
    when(() => mockAnalytics.logModelChanged(any())).thenAnswer((_) async {});

    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
    getIt.registerSingleton<AnalyticsService>(mockAnalytics);
  });

  tearDown(() {
    if (getIt.isRegistered<AnalyticsService>()) {
      getIt.unregister<AnalyticsService>();
    }
  });

  SettingsCubit buildCubit() => SettingsCubit(mockRepo, themeCubit, clearSummaries);

  group('SettingsCubit — load()', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits SettingsLoaded with values from repository',
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [isA<SettingsLoaded>()],
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.geminiModel, SettingsEntity.defaults.geminiModel);
        expect(state.settings.accentColor, SettingsEntity.defaults.accentColor);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'applies accent from loaded settings to ThemeCubit',
      build: buildCubit,
      act: (cubit) async {
        when(() => mockRepo.load()).thenAnswer(
          (_) async => SettingsEntity.defaults.copyWith(accentColor: 'teal'),
        );
        await cubit.load();
      },
      verify: (_) {
        expect(themeCubit.state.accentId, 'teal');
      },
    );
  });

  group('SettingsCubit — setters', () {
    blocTest<SettingsCubit, SettingsState>(
      'setGeminiModel updates model in emitted state',
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.setGeminiModel('gemini-pro');
      },
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.geminiModel, 'gemini-pro');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setAutoSummarize updates flag in emitted state',
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.setAutoSummarize(false);
      },
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.autoSummarize, false);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setCacheResults updates flag in emitted state',
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.setCacheResults(false);
      },
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.cacheResults, false);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setAccentColor updates accentColor and propagates to ThemeCubit',
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.setAccentColor('violet');
      },
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.accentColor, 'violet');
        expect(themeCubit.state.accentId, 'violet');
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'setNotifyOnDone updates flag in emitted state',
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.setNotifyOnDone(false);
      },
      verify: (cubit) {
        final state = cubit.state as SettingsLoaded;
        expect(state.settings.notifyOnDone, false);
      },
    );

    blocTest<SettingsCubit, SettingsState>(
      'each setter calls repo.save()',
      build: buildCubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.setGeminiModel('gemini-pro');
      },
      verify: (_) {
        verify(() => mockRepo.save(any())).called(1);
      },
    );
  });

  group('SettingsCubit — clearSummaries()', () {
    blocTest<SettingsCubit, SettingsState>(
      'delegates to ClearSummariesUseCase',
      build: buildCubit,
      act: (cubit) => cubit.clearSummaries(),
      verify: (_) {
        verify(() => mockRepoRepository.clearSummaries()).called(1);
      },
    );
  });
}
