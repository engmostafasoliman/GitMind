import '../../domain/entities/chat_message.dart';

sealed class SendMessageState {
  final List<ChatMessage> messages;
  const SendMessageState(this.messages);

  List<ChatMessage> get visible => messages.where((m) => !m.isHidden).toList();
}

final class ChatIdle extends SendMessageState {
  const ChatIdle([super.messages = const []]);
}

final class ChatLoading extends SendMessageState {
  const ChatLoading(super.messages);
}

final class ChatError extends SendMessageState {
  final String error;
  const ChatError(super.messages, this.error);
}
