import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/chat/domain/entities/chat_message.dart';
import 'package:chaty_ai_agent/features/chat/domain/repositories/chat_repository.dart';
import 'package:chaty_ai_agent/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockRepository;
  late SendMessageUseCase useCase;

  setUp(() {
    mockRepository = MockChatRepository();
    useCase = SendMessageUseCase(mockRepository);
  });

  const tMessages = [
    ChatMessage(role: 'user', text: 'Hello'),
  ];

  const tReply = ChatMessage(role: 'model', text: 'Hi there!');

  group('SendMessageUseCase', () {
    test('returns ApiSuccess from repository on success', () async {
      when(() => mockRepository.sendMessage(tMessages))
          .thenAnswer((_) async => const ApiSuccess(tReply));

      final result = await useCase(tMessages);

      expect(result, isA<ApiSuccess<ChatMessage>>());
      expect((result as ApiSuccess).data.text, 'Hi there!');
    });

    test('returns ApiFailure from repository on failure', () async {
      when(() => mockRepository.sendMessage(tMessages))
          .thenAnswer((_) async => const ApiFailure('Something went wrong'));

      final result = await useCase(tMessages);

      expect(result, isA<ApiFailure<ChatMessage>>());
      expect((result as ApiFailure).message, 'Something went wrong');
    });

    test('delegates call to repository with exact messages', () async {
      when(() => mockRepository.sendMessage(tMessages))
          .thenAnswer((_) async => const ApiSuccess(tReply));

      await useCase(tMessages);

      verify(() => mockRepository.sendMessage(tMessages)).called(1);
    });
  });
}
