import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../theme/theme_cubit.dart';
import '../../features/chat/data/repositories/gemini_chat_repository_impl.dart';
import '../../features/chat/data/services/gemini_chat_service.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message_use_case.dart';
import '../../features/chat/presentation/cubit/send_message_cubit.dart';
import '../../features/repo_list/data/datasources/github_repo_data_source.dart';
import '../../features/repo_list/data/datasources/repo_data_source.dart';
import '../../features/repo_list/data/repositories/repo_repository_impl.dart';
import '../../features/repo_list/domain/repositories/repo_repository.dart';
import '../../features/repo_list/domain/usecases/get_repos_usecase.dart';
import '../../features/repo_list/domain/usecases/get_repo_detail_usecase.dart';
import '../../features/repo_list/domain/usecases/generate_summary_usecase.dart';
import '../../features/repo_list/presentation/cubit/repo_list_cubit.dart';
import '../../features/repo_detail/presentation/cubit/repo_detail_cubit.dart';
import '../../features/profile/domain/entities/user_entity.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/sign_in/data/datasources/firebase_auth_data_source.dart';
import '../../features/sign_in/data/repositories/auth_repository_impl.dart';
import '../../features/sign_in/domain/repositories/auth_repository.dart';
import '../../features/sign_in/domain/usecases/sign_in_with_github_usecase.dart';
import '../../features/sign_in/presentation/cubit/sign_in_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies(AppConfig config) {
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  // Auth
  getIt.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SignInWithGitHubUseCase>(
    () => SignInWithGitHubUseCase(getIt()),
  );
  getIt.registerFactory<SignInCubit>(
    () => SignInCubit(getIt()),
  );

  // Repos
  getIt.registerLazySingleton<RepoDataSource>(() => GitHubRepoDataSource());
  getIt.registerLazySingleton<RepoRepository>(
    () => RepoRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetReposUseCase>(
    () => GetReposUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetRepoDetailUseCase>(
    () => GetRepoDetailUseCase(getIt()),
  );
  getIt.registerLazySingleton<GenerateSummaryUseCase>(
    () => GenerateSummaryUseCase(getIt()),
  );
  getIt.registerFactory<RepoListCubit>(
    () => RepoListCubit(getIt()),
  );
  getIt.registerFactory<RepoDetailCubit>(
    () => RepoDetailCubit(getIt(), getIt()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt(), getIt<AuthRepository>().currentUser ?? kMockUser),
  );

  // Chat / Gemini
  getIt.registerLazySingleton<GeminiChatService>(
    () => GeminiChatService(apiKey: config.geminiApiKey),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => GeminiChatRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(getIt()),
  );
  getIt.registerFactory<SendMessageCubit>(
    () => SendMessageCubit(getIt()),
  );
}
