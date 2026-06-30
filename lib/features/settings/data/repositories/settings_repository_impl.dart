import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _keyModel = 'settings_gemini_model';
  static const _keyAutoSummarize = 'settings_auto_summarize';
  static const _keyCacheResults = 'settings_cache_results';
  static const _keyMinConfidence = 'settings_min_confidence';
  static const _keyAccentColor = 'settings_accent_color';
  static const _keyDensity = 'settings_density';
  static const _keyEmailDigest = 'settings_email_digest';
  static const _keyNotifyDone = 'settings_notify_done';

  @override
  Future<SettingsEntity> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsEntity(
      geminiModel: prefs.getString(_keyModel) ?? SettingsEntity.defaults.geminiModel,
      autoSummarize: prefs.getBool(_keyAutoSummarize) ?? SettingsEntity.defaults.autoSummarize,
      cacheResults: prefs.getBool(_keyCacheResults) ?? SettingsEntity.defaults.cacheResults,
      minConfidence: prefs.getString(_keyMinConfidence) ?? SettingsEntity.defaults.minConfidence,
      accentColor: prefs.getString(_keyAccentColor) ?? SettingsEntity.defaults.accentColor,
      density: prefs.getString(_keyDensity) ?? SettingsEntity.defaults.density,
      emailDigest: prefs.getBool(_keyEmailDigest) ?? SettingsEntity.defaults.emailDigest,
      notifyOnDone: prefs.getBool(_keyNotifyDone) ?? SettingsEntity.defaults.notifyOnDone,
    );
  }

  @override
  Future<void> save(SettingsEntity s) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyModel, s.geminiModel),
      prefs.setBool(_keyAutoSummarize, s.autoSummarize),
      prefs.setBool(_keyCacheResults, s.cacheResults),
      prefs.setString(_keyMinConfidence, s.minConfidence),
      prefs.setString(_keyAccentColor, s.accentColor),
      prefs.setString(_keyDensity, s.density),
      prefs.setBool(_keyEmailDigest, s.emailDigest),
      prefs.setBool(_keyNotifyDone, s.notifyOnDone),
    ]);
  }
}
