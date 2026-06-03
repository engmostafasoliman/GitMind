import '../../../../core/result/api_result.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  const SendMessageUseCase(this._repository);

  Future<ApiResult<ChatMessage>> call(List<ChatMessage> messages) =>
      _repository.sendMessage(messages);
}
