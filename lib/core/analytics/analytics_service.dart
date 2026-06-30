import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Auth
  Future<void> logSignIn() =>
      _analytics.logLogin(loginMethod: 'github');

  Future<void> logSignOut() =>
      _analytics.logEvent(name: 'sign_out');

  // Screens
  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  // Repo list
  Future<void> logRepoListLoaded(int count) =>
      _analytics.logEvent(name: 'repo_list_loaded', parameters: {'count': count});

  Future<void> logRepoSearch(String query) =>
      _analytics.logSearch(searchTerm: query);

  // Repo detail
  Future<void> logRepoViewed(String repoId, String repoName) =>
      _analytics.logEvent(name: 'repo_viewed', parameters: {
        'repo_id': repoId,
        'repo_name': repoName,
      });

  Future<void> logSummaryGenerated(String repoId, {bool regenerated = false}) =>
      _analytics.logEvent(name: 'summary_generated', parameters: {
        'repo_id': repoId,
        'regenerated': regenerated,
      });

  Future<void> logSummaryRateLimit(String repoId) =>
      _analytics.logEvent(name: 'summary_rate_limit', parameters: {
        'repo_id': repoId,
      });

  // Chat
  Future<void> logChatOpened(String repoId) =>
      _analytics.logEvent(name: 'chat_opened', parameters: {'repo_id': repoId});

  Future<void> logMessageSent(String repoId) =>
      _analytics.logEvent(name: 'message_sent', parameters: {'repo_id': repoId});

  Future<void> logChatRateLimit(String repoId) =>
      _analytics.logEvent(name: 'chat_rate_limit', parameters: {'repo_id': repoId});

  // Settings
  Future<void> logModelChanged(String model) =>
      _analytics.logEvent(name: 'model_changed', parameters: {'model': model});

  // Profile
  Future<void> logViewOnGitHub() =>
      _analytics.logEvent(name: 'view_on_github');
}
