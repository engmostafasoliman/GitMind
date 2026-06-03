import '../../domain/entities/chat_message.dart';

sealed class SendMessageState {
  const SendMessageState();
}

final class SendMessageInitial extends SendMessageState {
  const SendMessageInitial();
}

final class SendMessageLoading extends SendMessageState {
  const SendMessageLoading();
}

final class SendMessageSuccess extends SendMessageState {
  final ChatMessage message;
  const SendMessageSuccess(this.message);
}

final class SendMessageFailure extends SendMessageState {
  final String message;
  const SendMessageFailure(this.message);
}
