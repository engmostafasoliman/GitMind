import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isDark;
  final String? emptyLabel;

  const MessageList({
    super.key,
    required this.scrollController,
    required this.messages,
    required this.isDark,
    this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final visible = messages.where((m) => !m.isHidden).toList();

    if (visible.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent(isDark).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded, size: 24, color: AppColors.accent(isDark)),
            ),
            const SizedBox(height: 16),
            Text(
              emptyLabel ?? 'Start a conversation',
              style: TextStyle(fontSize: 15, color: AppColors.secondary(isDark)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final msg = visible[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: MessageBubble(
            text: msg.text,
            isUser: msg.role == 'user',
            isDark: isDark,
          ),
        );
      },
    );
  }
}
