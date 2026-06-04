import 'package:chaty_ai_agent/features/chat/data/models/chat_message_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatPart', () {
    const tJson = {'text': 'Hello'};
    const tPart = ChatPart(text: 'Hello');

    test('fromJson maps text correctly', () {
      expect(ChatPart.fromJson(tJson), isA<ChatPart>());
      expect(ChatPart.fromJson(tJson).text, 'Hello');
    });

    test('toJson returns correct map', () {
      expect(tPart.toJson(), tJson);
    });
  });

  group('ChatMessageModel', () {
    const tJson = {
      'role': 'user',
      'parts': [
        {'text': 'Explain how AI works'}
      ],
    };

    const tModel = ChatMessageModel(
      role: 'user',
      parts: [ChatPart(text: 'Explain how AI works')],
    );

    test('fromJson maps role and parts correctly', () {
      final result = ChatMessageModel.fromJson(tJson);
      expect(result.role, 'user');
      expect(result.parts.length, 1);
      expect(result.parts.first.text, 'Explain how AI works');
    });

    test('toJson returns correct map', () {
      expect(tModel.toJson(), tJson);
    });

    test('text getter joins all parts', () {
      const model = ChatMessageModel(
        role: 'model',
        parts: [ChatPart(text: 'Hello '), ChatPart(text: 'World')],
      );
      expect(model.text, 'Hello World');
    });

    test('fromJson roundtrip preserves data', () {
      final result = ChatMessageModel.fromJson(tModel.toJson());
      expect(result.role, tModel.role);
      expect(result.parts.first.text, tModel.parts.first.text);
    });
  });
}
