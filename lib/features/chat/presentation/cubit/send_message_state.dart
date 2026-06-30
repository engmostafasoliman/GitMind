import '../../domain/entities/chat_message.dart';

sealed class SendMessageState {
  final List<ChatMessage> messages;
  final bool isCoolingDown;
  const SendMessageState(this.messages, {this.isCoolingDown = false});

  List<ChatMessage> get visible => messages.where((m) => !m.isHidden).toList();
}

final class ChatIdle extends SendMessageState {
  const ChatIdle([List<ChatMessage> messages = const [], bool isCoolingDown = false])
      : super(messages, isCoolingDown: isCoolingDown);
}

final class ChatLoading extends SendMessageState {
  const ChatLoading(super.messages);
}

final class ChatError extends SendMessageState {
  final String error;
  const ChatError(super.messages, this.error);
}
