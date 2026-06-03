import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class GeminiChatService {
  final String apiKey;
  final String model;

  const GeminiChatService({
    required this.apiKey,
    this.model = 'gemini-3.5-flash',
  });

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<ChatMessageModel> sendMessages(
    List<ChatMessageModel> messages,
  ) async {
    final uri = Uri.parse('$_baseUrl/$model:generateContent');

    final body = jsonEncode({
      'contents': messages.map((m) => m.toJson()).toList(),
    });

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (json['candidates'] as List<dynamic>)[0]['content']
        as Map<String, dynamic>;

    return ChatMessageModel.fromJson(content);
  }
}
