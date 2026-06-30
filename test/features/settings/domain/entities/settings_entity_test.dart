import 'package:chaty_ai_agent/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsEntity.defaults', () {
    test('has expected default values', () {
      const d = SettingsEntity.defaults;
      expect(d.geminiModel, 'gemini-flash-latest');
      expect(d.autoSummarize, true);
      expect(d.cacheResults, true);
      expect(d.minConfidence, 'medium');
      expect(d.accentColor, 'indigo');
      expect(d.density, 'comfortable');
      expect(d.emailDigest, false);
      expect(d.notifyOnDone, true);
    });
  });

  group('SettingsEntity.copyWith', () {
    test('returns new instance with changed field', () {
      const original = SettingsEntity.defaults;
      final updated = original.copyWith(geminiModel: 'gemini-pro');
      expect(updated.geminiModel, 'gemini-pro');
    });

    test('preserves unchanged fields', () {
      const original = SettingsEntity.defaults;
      final updated = original.copyWith(accentColor: 'teal');
      expect(updated.accentColor, 'teal');
      expect(updated.geminiModel, original.geminiModel);
      expect(updated.autoSummarize, original.autoSummarize);
      expect(updated.cacheResults, original.cacheResults);
      expect(updated.notifyOnDone, original.notifyOnDone);
    });

    test('can toggle bool field', () {
      const original = SettingsEntity.defaults;
      final updated = original.copyWith(autoSummarize: false);
      expect(updated.autoSummarize, false);
      expect(original.autoSummarize, true);
    });

    test('calling with no args returns equal entity', () {
      const original = SettingsEntity.defaults;
      final copy = original.copyWith();
      expect(copy.geminiModel, original.geminiModel);
      expect(copy.accentColor, original.accentColor);
    });
  });
}
