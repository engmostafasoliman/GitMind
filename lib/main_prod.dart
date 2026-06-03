import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'features/chat/presentation/screens/chat_screen.dart';

void main() {
  const config = AppConfig(
    flavor: Flavor.prod,
    appName: 'Chaty Agent',
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
  );

  setupDependencies(config);
  runApp(MyApp(appName: config.appName));
}

class MyApp extends StatelessWidget {
  final String appName;
  const MyApp({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
