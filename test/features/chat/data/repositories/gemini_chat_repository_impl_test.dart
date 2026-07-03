import 'package:chaty_ai_agent/core/error/app_exception.dart';
import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/chat/data/models/chat_message_model.dart';
import 'package:chaty_ai_agent/features/chat/data/repositories/gemini_chat_repository_impl.dart';
import 'package:chaty_ai_agent/features/chat/data/services/gemini_chat_service.dart';
import 'package:chaty_ai_agent/features/chat/domain/entities/chat_message.dart';
import 'package:chaty_ai_agent/features/settings/domain/entities/settings_entity.dart';
import 'package:chaty_ai_agent/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGeminiChatService extends Mock implements GeminiChatService {}
class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockGeminiChatService mockService;
  late MockSettingsRepository mockSettingsRepo;
  late GeminiChatRepositoryImpl repository;

  setUp(() {
    mockService = MockGeminiChatService();
    mockSettingsRepo = MockSettingsRepository();
    when(() => mockSettingsRepo.load())
        .thenAnswer((_) async => SettingsEntity.defaults);
    repository = GeminiChatRepositoryImpl(mockService, mockSettingsRepo);
  });

  const tMessages = [
    ChatMessage(role: 'user', text: 'Explain how AI works'),
  ];

  const tResponseModel = ChatMessageModel(
    role: 'model',
    parts: [ChatPart(text: 'AI works by recognizing patterns.')],
  );

  group('sendMessage', () {
    test('returns ApiSuccess with ChatMessage on service success', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      final result = await repository.sendMessage(tMessages);

      expect(result, isA<ApiSuccess<ChatMessage>>());
      final success = result as ApiSuccess<ChatMessage>;
      expect(success.data.role, 'model');
      expect(success.data.text, 'AI works by recognizing patterns.');
    });

    test('returns ApiFailure with humanized message on NoInternetException',
        () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenThrow(const NoInternetException());

      final result = await repository.sendMessage(tMessages);

      expect(result, isA<ApiFailure<ChatMessage>>());
      final failure = result as ApiFailure<ChatMessage>;
      expect(failure.message, contains('No internet connection'));
    });

    test('returns ApiRateLimit on RateLimitException', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenThrow(const RateLimitException());

      final result = await repository.sendMessage(tMessages);

      expect(result, isA<ApiRateLimit<ChatMessage>>());
    });

    test('returns ApiFailure with humanized message on ServerException',
        () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenThrow(const ServerException(503));

      final result = await repository.sendMessage(tMessages);

      final failure = result as ApiFailure<ChatMessage>;
      expect(failure.message, contains('AI service is having trouble'));
    });

    test('returns ApiFailure with generic message on unknown error', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenThrow(Exception('unknown'));

      final result = await repository.sendMessage(tMessages);

      final failure = result as ApiFailure<ChatMessage>;
      expect(failure.message, contains('Something went wrong'));
    });

    test('passes correct number of messages to service', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      await repository.sendMessage(tMessages);

      final captured =
          verify(() => mockService.sendMessages(captureAny(), model: any(named: 'model'))).captured;
      final sentModels = captured.first as List<ChatMessageModel>;
      expect(sentModels.length, 1);
      expect(sentModels.first.role, 'user');
      expect(sentModels.first.parts.first.text, 'Explain how AI works');
    });

    test('passes geminiModel from settings to service', () async {
      when(() => mockSettingsRepo.load()).thenAnswer(
        (_) async => SettingsEntity.defaults.copyWith(geminiModel: 'gemini-2.5-pro'),
      );
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      await repository.sendMessage(tMessages);

      final captured =
          verify(() => mockService.sendMessages(any(), model: captureAny(named: 'model'))).captured;
      expect(captured.first, 'gemini-2.5-pro');
    });
  });

  group('sendMessage — history trimming', () {
    List<ChatMessage> makeHistory({
      required int hiddenCount,
      required int visibleCount,
    }) {
      return [
        for (var i = 0; i < hiddenCount; i++)
          ChatMessage(role: i.isEven ? 'user' : 'model', text: 'hidden $i', isHidden: true),
        for (var i = 0; i < visibleCount; i++)
          ChatMessage(role: i.isEven ? 'user' : 'model', text: 'visible $i'),
      ];
    }

    test('sends all messages when visible count is within limit', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      final messages = makeHistory(hiddenCount: 2, visibleCount: 5);
      await repository.sendMessage(messages);

      final captured = verify(() => mockService.sendMessages(captureAny(), model: any(named: 'model'))).captured;
      final sent = captured.first as List<ChatMessageModel>;
      expect(sent.length, 7); // 2 hidden + 5 visible
    });

    test('caps visible history at 10 messages, keeps all hidden', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      final messages = makeHistory(hiddenCount: 2, visibleCount: 15);
      await repository.sendMessage(messages);

      final captured = verify(() => mockService.sendMessages(captureAny(), model: any(named: 'model'))).captured;
      final sent = captured.first as List<ChatMessageModel>;
      expect(sent.length, 12); // 2 hidden + last 10 visible
    });

    test('keeps the most recent visible messages when trimming', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      final messages = makeHistory(hiddenCount: 0, visibleCount: 12);
      await repository.sendMessage(messages);

      final captured = verify(() => mockService.sendMessages(captureAny(), model: any(named: 'model'))).captured;
      final sent = captured.first as List<ChatMessageModel>;
      // Last 10 visible → texts "visible 2" through "visible 11"
      expect(sent.first.parts.first.text, 'visible 2');
      expect(sent.last.parts.first.text, 'visible 11');
    });

    test('always preserves hidden system context before visible history', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenAnswer((_) async => tResponseModel);

      final messages = makeHistory(hiddenCount: 2, visibleCount: 15);
      await repository.sendMessage(messages);

      final captured = verify(() => mockService.sendMessages(captureAny(), model: any(named: 'model'))).captured;
      final sent = captured.first as List<ChatMessageModel>;
      expect(sent[0].parts.first.text, 'hidden 0');
      expect(sent[1].parts.first.text, 'hidden 1');
    });

    test('returns ApiRateLimit when service throws RateLimitException', () async {
      when(() => mockService.sendMessages(any(), model: any(named: 'model')))
          .thenThrow(const RateLimitException());

      final result = await repository.sendMessage(tMessages);

      expect(result, isA<ApiRateLimit<ChatMessage>>());
    });
  });
}
