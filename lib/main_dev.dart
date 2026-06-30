import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/theme/theme_cubit.dart';
import 'firebase_options.dart';
import 'features/profile/domain/entities/user_entity.dart';
import 'features/repo_list/presentation/cubit/repo_list_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/sign_in/presentation/screens/sign_in_screen.dart';
import 'features/repo_list/presentation/screens/repo_list_screen.dart';
import 'features/repo_detail/presentation/screens/repo_detail_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const config = AppConfig(
    flavor: Flavor.dev,
    appName: 'Chaty Agent Dev',
    geminiApiKey: String.fromEnvironment('GEMINI_API_KEY'),
  );
  setupDependencies(config);
  runApp(MyApp(appName: config.appName, isDev: true));
}

final _navigatorKey = GlobalKey<NavigatorState>();

void _goToSettings() => _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          onSignOut: () => _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => SignInScreen(onSignIn: (_) {})),
            (route) => false,
          ),
        ),
      ),
    );

void _goToDetail(String repoId) => _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => RepoDetailScreen(
          repoId: repoId,
          onProfile: _goToProfile,
          onSettings: _goToSettings,
        ),
      ),
    );

void _goToProfile() => _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          onRepoTap: _goToDetail,
          onSettings: _goToSettings,
        ),
      ),
    );

class MyApp extends StatelessWidget {
  final String appName;
  final bool isDev;
  const MyApp({super.key, required this.appName, this.isDev = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => getIt<ThemeCubit>()),
        BlocProvider<RepoListCubit>(create: (_) => getIt<RepoListCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()..load()),
      ],
      child: BlocBuilder<ThemeCubit, AppThemeData>(
        builder: (context, theme) {
          return MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: isDev,
            navigatorKey: _navigatorKey,
            themeMode: theme.mode,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: SignInScreen(
              onSignIn: (UserEntity user) =>
                  _navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RepoListScreen(
                    onRepoTap: _goToDetail,
                    onProfile: _goToProfile,
                    onSettings: _goToSettings,
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
