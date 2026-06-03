import '../../../../core/result/api_result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';
import '../services/gemini_chat_service.dart';

class GeminiChatRepositoryImpl implements ChatRepository {
  final GeminiChatService _service;

  const GeminiChatRepositoryImpl(this._service);

  @override
  Future<ApiResult<ChatMessage>> sendMessage(List<ChatMessage> messages) async {
    try {
      final models = messages
          .map((m) => ChatMessageModel(
                role: m.role,
                parts: [ChatPart(text: m.text)],
              ))
          .toList();

      final response = await _service.sendMessages(models);

      return ApiSuccess(ChatMessage(role: response.role, text: response.text));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
}
