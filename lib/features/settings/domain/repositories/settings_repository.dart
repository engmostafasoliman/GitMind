import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> load();
  Future<void> save(SettingsEntity settings);
}
