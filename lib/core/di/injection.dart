import 'package:get_it/get_it.dart';

import '../../features/chat/data/repositories/gemini_chat_repository_impl.dart';
import '../../features/chat/data/services/gemini_chat_service.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message_use_case.dart';
import '../../features/chat/presentation/cubit/send_message_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<GeminiChatService>(
    () => const GeminiChatService(apiKey: 'YOUR_GEMINI_API_KEY'),
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
