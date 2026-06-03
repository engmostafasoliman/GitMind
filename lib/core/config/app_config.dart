enum Flavor { dev, prod }

class AppConfig {
  final Flavor flavor;
  final String appName;
  final String geminiApiKey;

  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.geminiApiKey,
  });

  bool get isDev => flavor == Flavor.dev;
}
