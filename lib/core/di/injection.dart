import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../theme/theme_cubit.dart';
import '../../features/chat/data/repositories/gemini_chat_repository_impl.dart';
import '../../features/chat/data/services/gemini_chat_service.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message_use_case.dart';
import '../../features/chat/presentation/cubit/send_message_cubit.dart';
import '../../features/repo_list/data/datasources/repo_mock_data_source.dart';
import '../../features/repo_list/data/repositories/repo_repository_impl.dart';
import '../../features/repo_list/domain/repositories/repo_repository.dart';
import '../../features/repo_list/domain/usecases/get_repos_usecase.dart';
import '../../features/repo_list/presentation/cubit/repo_list_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies(AppConfig config) {
  getIt.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  getIt.registerLazySingleton<RepoMockDataSource>(() => RepoMockDataSource());
  getIt.registerLazySingleton<RepoRepository>(
    () => RepoRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<GetReposUseCase>(
    () => GetReposUseCase(getIt()),
  );
  getIt.registerFactory<RepoListCubit>(
    () => RepoListCubit(getIt()),
  );
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
