import '../../domain/entities/settings_entity.dart';

sealed class SettingsState {
  const SettingsState();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;
  const SettingsLoaded(this.settings);
}
