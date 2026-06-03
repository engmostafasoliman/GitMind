import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/chat_message.dart';
import '../cubit/send_message_cubit.dart';
import '../cubit/send_message_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_list.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SendMessageCubit>(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];

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

    final userMessage = ChatMessage(role: 'user', text: text);

    setState(() => _messages.add(userMessage));
    _controller.clear();
    _scrollToBottom();

    context.read<SendMessageCubit>().sendMessage(List.from(_messages));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendMessageCubit, SendMessageState>(
      listener: (context, state) {
        if (state is SendMessageSuccess) {
          setState(() => _messages.add(state.message));
          _scrollToBottom();
        } else if (state is SendMessageFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SendMessageLoading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chaty Agent'),
            centerTitle: true,
            leading: BackButton(onPressed: () => Navigator.maybePop(context)),
          ),
          body: Column(
            children: [
              Expanded(
                child: MessageList(
                  scrollController: _scrollController,
                  messages: _messages,
                ),
              ),
              if (isLoading)
                const LinearProgressIndicator(),
              ChatInputBar(
                controller: _controller,
                focusNode: _focusNode,
                onSend: isLoading ? () {} : _send,
              ),
            ],
          ),
        );
      },
    );
  }
}
