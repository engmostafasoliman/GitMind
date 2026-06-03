import 'package:flutter/material.dart';

import '../../domain/entities/chat_message.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;

  const MessageList({
    super.key,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Start a conversation',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          text: message.text,
          isUser: message.role == 'user',
        );
      },
    );
  }
}
