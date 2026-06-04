import 'package:bloc_test/bloc_test.dart';
import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/chat/domain/entities/chat_message.dart';
import 'package:chaty_ai_agent/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:chaty_ai_agent/features/chat/presentation/cubit/send_message_cubit.dart';
import 'package:chaty_ai_agent/features/chat/presentation/cubit/send_message_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  late MockSendMessageUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockSendMessageUseCase();
  });

  const tMessages = [
    ChatMessage(role: 'user', text: 'Explain AI'),
  ];

  const tReply = ChatMessage(role: 'model', text: 'AI is...');

  group('SendMessageCubit', () {
    test('initial state is SendMessageInitial', () {
      expect(
        SendMessageCubit(mockUseCase).state,
        isA<SendMessageInitial>(),
      );
    });

    blocTest<SendMessageCubit, SendMessageState>(
      'emits [Loading, Success] when use case returns ApiSuccess',
      build: () {
        when(() => mockUseCase(tMessages))
            .thenAnswer((_) async => const ApiSuccess(tReply));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.sendMessage(tMessages),
      expect: () => [
        isA<SendMessageLoading>(),
        isA<SendMessageSuccess>(),
      ],
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'emits [Loading, Failure] when use case returns ApiFailure',
      build: () {
        when(() => mockUseCase(tMessages))
            .thenAnswer((_) async => const ApiFailure('Error occurred'));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.sendMessage(tMessages),
      expect: () => [
        isA<SendMessageLoading>(),
        isA<SendMessageFailure>(),
      ],
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'Success state contains correct message',
      build: () {
        when(() => mockUseCase(tMessages))
            .thenAnswer((_) async => const ApiSuccess(tReply));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.sendMessage(tMessages),
      verify: (cubit) {
        final state = cubit.state as SendMessageSuccess;
        expect(state.message.text, 'AI is...');
        expect(state.message.role, 'model');
      },
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'Failure state contains correct message',
      build: () {
        when(() => mockUseCase(tMessages))
            .thenAnswer((_) async => const ApiFailure('Error occurred'));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.sendMessage(tMessages),
      verify: (cubit) {
        final state = cubit.state as SendMessageFailure;
        expect(state.message, 'Error occurred');
      },
    );
  });
}
