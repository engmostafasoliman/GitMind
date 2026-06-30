import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import '../cubit/send_message_cubit.dart';
import '../cubit/send_message_state.dart';
import '../widgets/message_list.dart';

class ChatScreen extends StatelessWidget {
  final RepoEntity? repo;

  const ChatScreen({super.key, this.repo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<SendMessageCubit>();
        if (repo != null) cubit.initWithRepo(repo!);
        return cubit;
      },
      child: _ChatView(repo: repo),
    );
  }
}

class _ChatView extends StatefulWidget {
  final RepoEntity? repo;
  const _ChatView({this.repo});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    context.read<SendMessageCubit>().send(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeData>(
      builder: (context, theme) {
        final isDark = theme.isDark;
        return BlocConsumer<SendMessageCubit, SendMessageState>(
          listener: (context, state) {
            _scrollToBottom();
          },
          builder: (context, state) {
            final isLoading = state is ChatLoading;
            final errorMsg = state is ChatError ? state.error : null;
            final title = widget.repo != null
                ? 'Ask about ${widget.repo!.name}'
                : 'Chaty Agent';
            final emptyLabel = widget.repo != null
                ? 'Ask anything about\n${widget.repo!.name}'
                : 'Start a conversation';

            return Scaffold(
              backgroundColor: AppColors.bg(isDark),
              appBar: AppBar(
                backgroundColor: AppColors.bg(isDark),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.text(isDark)),
                  onPressed: () => Navigator.maybePop(context),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(isDark),
                      ),
                    ),
                    if (widget.repo != null)
                      Text(
                        'Powered by Gemini',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary(isDark),
                        ),
                      ),
                  ],
                ),
                centerTitle: true,
                bottom: isLoading
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(2),
                        child: LinearProgressIndicator(
                          color: AppColors.accent(isDark),
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    : null,
              ),
              body: Column(
                children: [
                  Divider(
                    height: 1,
                    color: AppColors.border(isDark),
                  ),
                  Expanded(
                    child: MessageList(
                      scrollController: _scrollController,
                      messages: state.messages,
                      isDark: isDark,
                      emptyLabel: emptyLabel,
                    ),
                  ),
                  if (errorMsg != null)
                    _ErrorCard(
                      message: errorMsg,
                      isDark: isDark,
                      onRetry: () => context.read<SendMessageCubit>().retry(),
                      onDismiss: () => context.read<SendMessageCubit>().dismissError(),
                    ),
                  _ChatInputBar(
                    controller: _controller,
                    focusNode: _focusNode,
                    isLoading: isLoading,
                    isCoolingDown: state.isCoolingDown,
                    isDark: isDark,
                    onSend: _send,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _ErrorCard({
    required this.message,
    required this.isDark,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger(isDark).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger(isDark).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: AppColors.danger(isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: AppColors.danger(isDark)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.danger(isDark),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Retry', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 18, color: AppColors.secondary(isDark)),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool isCoolingDown;
  final bool isDark;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.isCoolingDown,
    required this.isDark,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(isDark);
    final blocked = isLoading || isCoolingDown;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bg(isDark),
          border: Border(top: BorderSide(color: AppColors.border(isDark))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !blocked,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: TextStyle(color: AppColors.text(isDark), fontSize: 15),
                decoration: InputDecoration(
                  hintText: isCoolingDown ? 'Wait a moment...' : 'Message...',
                  hintStyle: TextStyle(color: AppColors.secondary(isDark)),
                  filled: true,
                  fillColor: AppColors.surface(isDark),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: blocked ? null : onSend,
              icon: Icon(
                isCoolingDown ? Icons.hourglass_top_rounded : Icons.send_rounded,
              ),
              style: IconButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: accent.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
