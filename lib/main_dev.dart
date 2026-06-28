import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/theme/theme_cubit.dart';
import 'features/sign_in/presentation/screens/sign_in_screen.dart';
import 'features/repo_list/presentation/screens/repo_list_screen.dart';
import 'features/repo_detail/presentation/screens/repo_detail_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

void main() {
  const config = AppConfig(
    flavor: Flavor.dev,
    appName: 'Chaty Agent Dev',
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
  );
  setupDependencies(config);
  runApp(MyApp(appName: config.appName, isDev: true));
}

final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String appName;
  final bool isDev;
  const MyApp({super.key, required this.appName, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: isDev,
            navigatorKey: _navigatorKey,
            themeMode: themeMode,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: SignInScreen(
              onSignIn: () => _navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RepoListScreen(
                    onRepoTap: (id) => _navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (_) => RepoDetailScreen(repoId: id)),
                    ),
                    onProfile: () => _navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          onRepoTap: (id) => _navigatorKey.currentState?.push(
                            MaterialPageRoute(builder: (_) => RepoDetailScreen(repoId: id)),
                          ),
                          onSettings: () => _navigatorKey.currentState?.push(
                            MaterialPageRoute(builder: (_) => SettingsScreen(
                              onSignOut: () => _navigatorKey.currentState?.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => SignInScreen(onSignIn: () {})),
                                (route) => false,
                              ),
                            )),
                          ),
                        ),
                      ),
                    ),
                    onSettings: () => _navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (_) => SettingsScreen(
                        onSignOut: () => _navigatorKey.currentState?.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => SignInScreen(onSignIn: () {})),
                          (route) => false,
                        ),
                      )),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
