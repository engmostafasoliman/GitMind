import 'package:chaty_ai_agent/core/analytics/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late AnalyticsService service;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    service = AnalyticsService(analytics: mockAnalytics);

    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    when(() => mockAnalytics.logLogin(loginMethod: any(named: 'loginMethod')))
        .thenAnswer((_) async {});

    when(() => mockAnalytics.logSearch(searchTerm: any(named: 'searchTerm')))
        .thenAnswer((_) async {});

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});
  });

  group('logSummaryGenerated — regenerated param must be int not bool', () {
    test('passes regenerated=0 when regenerated is false (default)', () async {
      await service.logSummaryGenerated('repo_123');

      final captured = verify(
        () => mockAnalytics.logEvent(
          name: 'summary_generated',
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured;

      final params = captured.first as Map<String, Object>;
      expect(params['regenerated'], 0);
      expect(params['regenerated'], isA<int>());
      expect(params['repo_id'], 'repo_123');
    });

    test('passes regenerated=1 when regenerated is true', () async {
      await service.logSummaryGenerated('repo_123', regenerated: true);

      final captured = verify(
        () => mockAnalytics.logEvent(
          name: 'summary_generated',
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured;

      final params = captured.first as Map<String, Object>;
      expect(params['regenerated'], 1);
      expect(params['regenerated'], isA<int>());
    });

    test('regenerated param is never a bool', () async {
      await service.logSummaryGenerated('repo_123', regenerated: false);
      await service.logSummaryGenerated('repo_123', regenerated: true);

      final captured = verify(
        () => mockAnalytics.logEvent(
          name: 'summary_generated',
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured;

      for (final c in captured) {
        final params = c as Map<String, Object>;
        expect(params['regenerated'], isNot(isA<bool>()));
      }
    });
  });

  group('other analytics events', () {
    test('logRepoListLoaded passes count as int', () async {
      await service.logRepoListLoaded(42);

      final captured = verify(
        () => mockAnalytics.logEvent(
          name: 'repo_list_loaded',
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured;

      final params = captured.first as Map<String, Object>;
      expect(params['count'], 42);
    });

    test('logRepoViewed passes repo_id and repo_name', () async {
      await service.logRepoViewed('42', 'flutter');

      final captured = verify(
        () => mockAnalytics.logEvent(
          name: 'repo_viewed',
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured;

      final params = captured.first as Map<String, Object>;
      expect(params['repo_id'], '42');
      expect(params['repo_name'], 'flutter');
    });

    test('logModelChanged passes model name', () async {
      await service.logModelChanged('gemini-flash-latest');

      final captured = verify(
        () => mockAnalytics.logEvent(
          name: 'model_changed',
          parameters: captureAny(named: 'parameters'),
        ),
      ).captured;

      expect((captured.first as Map<String, Object>)['model'], 'gemini-flash-latest');
    });
  });
}
