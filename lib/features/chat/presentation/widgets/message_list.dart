import 'package:flutter/material.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final ScrollController scrollController;

  const MessageList({super.key, required this.scrollController});

  static const List<(String text, bool isUser)> _mockMessages = [
    ('Hello! How can I help you today?', false),
    ('Explain how AI works', true),
    (
      'AI works by training models on large datasets to recognize patterns and make predictions.',
      false
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_mockMessages.isEmpty) {
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
      itemCount: _mockMessages.length,
      itemBuilder: (context, index) {
        final (text, isUser) = _mockMessages[index];
        return MessageBubble(text: text, isUser: isUser);
      },
    );
  }
}
