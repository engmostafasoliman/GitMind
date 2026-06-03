class ChatPart {
  final String text;

  const ChatPart({required this.text});

  factory ChatPart.fromJson(Map<String, dynamic> json) =>
      ChatPart(text: json['text'] as String);

  Map<String, dynamic> toJson() => {'text': text};
}

class ChatMessageModel {
  final String role;
  final List<ChatPart> parts;

  const ChatMessageModel({required this.role, required this.parts});

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        role: json['role'] as String,
        parts: (json['parts'] as List<dynamic>)
            .map((p) => ChatPart.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': parts.map((p) => p.toJson()).toList(),
      };

  String get text => parts.map((p) => p.text).join();
}
