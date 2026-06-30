import 'package:chaty_ai_agent/features/chat/domain/entities/chat_message.dart';
import 'package:chaty_ai_agent/features/chat/presentation/cubit/send_message_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const visible = ChatMessage(role: 'user', text: 'hello');
  const hidden = ChatMessage(role: 'user', text: 'system', isHidden: true);

  group('SendMessageState.visible', () {
    test('filters out hidden messages', () {
      final state = ChatIdle([visible, hidden]);
      expect(state.visible, [visible]);
    });

    test('returns all messages when none are hidden', () {
      final state = ChatIdle([visible, visible]);
      expect(state.visible.length, 2);
    });

    test('returns empty list when all messages are hidden', () {
      final state = ChatIdle([hidden, hidden]);
      expect(state.visible, isEmpty);
    });

    test('ChatLoading.visible also filters hidden messages', () {
      final state = ChatLoading([hidden, visible]);
      expect(state.visible, [visible]);
    });

    test('ChatError.visible also filters hidden messages', () {
      final state = ChatError([hidden, visible], 'err');
      expect(state.visible, [visible]);
    });
  });
}
