import 'package:flutter/material.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chaty Agent'),
        centerTitle: true,
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(scrollController: _scrollController),
          ),
          ChatInputBar(
            controller: _controller,
            focusNode: _focusNode,
            onSend: () {},
          ),
        ],
      ),
    );
  }
}
