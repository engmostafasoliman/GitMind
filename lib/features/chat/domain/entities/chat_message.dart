class ChatMessage {
  final String role;
  final String text;
  final bool isHidden;

  const ChatMessage({
    required this.role,
    required this.text,
    this.isHidden = false,
  });
}
