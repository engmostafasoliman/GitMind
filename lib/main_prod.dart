import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/theme/theme_cubit.dart';
import 'features/sign_in/presentation/screens/sign_in_screen.dart';
import 'features/repo_list/presentation/screens/repo_list_screen.dart';
import 'features/repo_detail/presentation/screens/repo_detail_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

void main() {
  const config = AppConfig(
    flavor: Flavor.prod,
    appName: 'Chaty Agent',
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
  );
  setupDependencies(config);
  runApp(const MyApp(appName: 'Chaty Agent'));
}

final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  final String appName;
  const MyApp({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: false,
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
                        ),
                      ),
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
