import '../../../../core/error/app_exception.dart';
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
    } on RateLimitException {
      return const ApiRateLimit();
    } on AppException catch (e) {
      return ApiFailure(_humanize(e));
    } catch (e) {
      return const ApiFailure(
        'Something went wrong. Please try again.',
      );
    }
  }

  String _humanize(AppException exception) {
    return switch (exception) {
      NoInternetException() =>
        'No internet connection. Please check your network and try again.',
      TimeoutException() =>
        'The request took too long. Please try again.',
      RateLimitException() =>
        'Gemini API quota reached. Wait a few seconds and try again.',
      UnauthorizedException() =>
        'Authentication failed. Please check your API key.',
      ServerException() =>
        'The AI service is having trouble right now. Please try again in a moment.',
      UnknownException() =>
        'Something went wrong. Please try again.',
    };
  }
}
