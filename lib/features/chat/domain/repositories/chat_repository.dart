import '../../../../core/result/api_result.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<ApiResult<ChatMessage>> sendMessage(List<ChatMessage> messages);
}
