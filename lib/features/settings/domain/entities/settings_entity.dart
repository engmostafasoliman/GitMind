class SettingsEntity {
  final String geminiModel;
  final bool autoSummarize;
  final bool cacheResults;
  final String minConfidence;
  final String accentColor;
  final String density;
  final bool emailDigest;
  final bool notifyOnDone;

  const SettingsEntity({
    required this.geminiModel,
    required this.autoSummarize,
    required this.cacheResults,
    required this.minConfidence,
    required this.accentColor,
    required this.density,
    required this.emailDigest,
    required this.notifyOnDone,
  });

  static const defaults = SettingsEntity(
    geminiModel: 'gemini-flash-latest',
    autoSummarize: true,
    cacheResults: true,
    minConfidence: 'medium',
    accentColor: 'indigo',
    density: 'comfortable',
    emailDigest: false,
    notifyOnDone: true,
  );

  SettingsEntity copyWith({
    String? geminiModel,
    bool? autoSummarize,
    bool? cacheResults,
    String? minConfidence,
    String? accentColor,
    String? density,
    bool? emailDigest,
    bool? notifyOnDone,
  }) =>
      SettingsEntity(
        geminiModel: geminiModel ?? this.geminiModel,
        autoSummarize: autoSummarize ?? this.autoSummarize,
        cacheResults: cacheResults ?? this.cacheResults,
        minConfidence: minConfidence ?? this.minConfidence,
        accentColor: accentColor ?? this.accentColor,
        density: density ?? this.density,
        emailDigest: emailDigest ?? this.emailDigest,
        notifyOnDone: notifyOnDone ?? this.notifyOnDone,
      );
}
