import 'package:bloc_test/bloc_test.dart';
import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/chat/domain/entities/chat_message.dart';
import 'package:chaty_ai_agent/features/chat/domain/usecases/send_message_use_case.dart';
import 'package:chaty_ai_agent/features/chat/presentation/cubit/send_message_cubit.dart';
import 'package:chaty_ai_agent/features/chat/presentation/cubit/send_message_state.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/entities/repo_entity.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/entities/repo_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  late MockSendMessageUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockSendMessageUseCase();
    registerFallbackValue(<ChatMessage>[]);
  });

  const tReply = ChatMessage(role: 'model', text: 'AI is...');

  RepoEntity repoWithSummary() => const RepoEntity(
        id: '1',
        name: 'my-repo',
        owner: 'user',
        description: 'A test repo',
        language: 'Dart',
        stars: 10,
        license: 'MIT',
        lastCommit: 'today',
        updatedAgo: '1d ago',
        summarized: true,
        summary: RepoSummaryEntity(
          whatItDoes: 'It does stuff',
          techStack: ['Flutter', 'Dart'],
          strengths: ['Fast'],
          weaknesses: ['No tests'],
          confidence: ConfidenceLevel.high,
        ),
      );

  group('SendMessageCubit — initial state', () {
    test('starts as ChatIdle with empty messages', () {
      final cubit = SendMessageCubit(mockUseCase);
      expect(cubit.state, isA<ChatIdle>());
      expect(cubit.state.messages, isEmpty);
    });
  });

  group('SendMessageCubit — send()', () {
    blocTest<SendMessageCubit, SendMessageState>(
      'emits [ChatLoading, ChatIdle] on success',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiSuccess(tReply));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.send('Explain AI'),
      expect: () => [isA<ChatLoading>(), isA<ChatIdle>()],
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'emits [ChatLoading, ChatError] on failure',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiFailure('Error occurred'));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.send('Explain AI'),
      expect: () => [isA<ChatLoading>(), isA<ChatError>()],
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'ChatIdle after success contains user message and reply',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiSuccess(tReply));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.send('Explain AI'),
      verify: (cubit) {
        final state = cubit.state as ChatIdle;
        expect(state.messages.length, 2);
        expect(state.messages[0].role, 'user');
        expect(state.messages[0].text, 'Explain AI');
        expect(state.messages[1].text, 'AI is...');
      },
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'ChatError contains error message',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiFailure('Error occurred'));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.send('Explain AI'),
      verify: (cubit) {
        final state = cubit.state as ChatError;
        expect(state.error, 'Error occurred');
      },
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'trims whitespace from text before sending',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiSuccess(tReply));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) => cubit.send('  hello  '),
      verify: (cubit) {
        final state = cubit.state as ChatIdle;
        expect(state.messages.first.text, 'hello');
      },
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'does nothing when text is empty or whitespace',
      build: () => SendMessageCubit(mockUseCase),
      act: (cubit) async {
        await cubit.send('');
        await cubit.send('   ');
      },
      expect: () => [],
    );
  });

  group('SendMessageCubit — dismissError()', () {
    blocTest<SendMessageCubit, SendMessageState>(
      'transitions ChatError → ChatIdle preserving messages',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiFailure('oops'));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) async {
        await cubit.send('hello');
        cubit.dismissError();
      },
      verify: (cubit) {
        expect(cubit.state, isA<ChatIdle>());
        expect(cubit.state.messages.isNotEmpty, true);
      },
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'does nothing when state is not ChatError',
      build: () => SendMessageCubit(mockUseCase),
      act: (cubit) => cubit.dismissError(),
      expect: () => [],
    );
  });

  group('SendMessageCubit — initWithRepo()', () {
    blocTest<SendMessageCubit, SendMessageState>(
      'emits ChatIdle with 2 hidden messages when repo has a summary',
      build: () => SendMessageCubit(mockUseCase),
      act: (cubit) => cubit.initWithRepo(repoWithSummary()),
      verify: (cubit) {
        final state = cubit.state as ChatIdle;
        expect(state.messages.length, 2);
        expect(state.messages[0].isHidden, true);
        expect(state.messages[0].role, 'user');
        expect(state.messages[1].isHidden, true);
        expect(state.messages[1].role, 'model');
        expect(state.visible, isEmpty);
      },
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'does nothing when repo has no summary',
      build: () => SendMessageCubit(mockUseCase),
      act: (cubit) => cubit.initWithRepo(
        const RepoEntity(
          id: '1', name: 'r', owner: 'u', description: '', language: 'Dart',
          stars: 0, license: '', lastCommit: '', updatedAgo: '', summarized: false,
        ),
      ),
      expect: () => [],
    );

    blocTest<SendMessageCubit, SendMessageState>(
      'subsequent send after initWithRepo includes hidden messages in history',
      build: () {
        when(() => mockUseCase(any())).thenAnswer((_) async => const ApiSuccess(tReply));
        return SendMessageCubit(mockUseCase);
      },
      act: (cubit) async {
        cubit.initWithRepo(repoWithSummary());
        await cubit.send('What does it do?');
      },
      verify: (cubit) {
        final state = cubit.state as ChatIdle;
        // 2 hidden priming + 1 user + 1 reply
        expect(state.messages.length, 4);
        expect(state.visible.length, 2);
      },
    );
  });
}
