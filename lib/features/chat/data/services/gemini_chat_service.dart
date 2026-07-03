import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/error/app_exception.dart';
import '../models/chat_message_model.dart';

class GeminiChatService {
  final String apiKey;
  final String model;

  const GeminiChatService({
    required this.apiKey,
    this.model = 'gemini-flash-latest',
  });

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  Future<ChatMessageModel> sendMessages(List<ChatMessageModel> messages,
      {String? model}) async {
    final effectiveModel = model ?? this.model;
    final uri = Uri.parse('$_baseUrl/$effectiveModel:generateContent');
    final body = jsonEncode({
      'contents': messages.map((m) => m.toJson()).toList(),
    });

    return _sendWithRetry(uri, body, attempt: 1);
  }

  Future<ChatMessageModel> _sendWithRetry(
    Uri uri,
    String body, {
    required int attempt,
  }) async {
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      final statusCode = response.statusCode;

      if (statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = (json['candidates'] as List<dynamic>)[0]['content']
            as Map<String, dynamic>;
        return ChatMessageModel.fromJson(content);
      }

      if (statusCode >= 500 && attempt < _maxRetries) {
        await async.Future.delayed(_retryDelay * attempt);
        return _sendWithRetry(uri, body, attempt: attempt + 1);
      }

      _throwForStatus(statusCode);
    } on SocketException {
      throw const NoInternetException();
    } on async.TimeoutException {
      throw const TimeoutException();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }

  }

  Never _throwForStatus(int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
        throw const UnauthorizedException();
      case 429:
        throw const RateLimitException();
      case >= 500:
        throw ServerException(statusCode);
      default:
        throw UnknownException('Status $statusCode');
    }
  }
}
