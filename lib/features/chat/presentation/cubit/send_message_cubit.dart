import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/api_result.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_use_case.dart';
import 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final SendMessageUseCase _useCase;
  final AnalyticsService _analytics;
  Timer? _cooldownTimer;
  Timer? _rateLimitTimer;
  String _repoId = '';

  static const _cooldownDuration = Duration(seconds: 5);
  static const _rateLimitRetrySeconds = 15;

  SendMessageCubit(this._useCase, {AnalyticsService? analytics})
      : _analytics = analytics ?? getIt<AnalyticsService>(),
        super(const ChatIdle());

  void initWithRepo(RepoEntity repo) {
    _repoId = repo.id;
    _analytics.logChatOpened(repo.id);
    final s = repo.summary;
    if (s == null) return;

    final prompt =
        'You are a helpful code reviewer and software architect. '
        'The user wants to discuss the "${repo.name}" repository by ${repo.owner}.\n\n'
        'Repository context:\n'
        '- What it does: ${s.whatItDoes}\n'
        '- Tech stack: ${s.techStack.join(', ')}\n'
        '- Strengths: ${s.strengths.join('; ')}\n'
        '- Weaknesses: ${s.weaknesses.join('; ')}\n'
        '- Primary language: ${repo.language}\n'
        '- Stars: ${repo.stars}\n\n'
        'Answer concisely and always relate your answers to this specific repository.';

    emit(ChatIdle([
      ChatMessage(role: 'user', text: prompt, isHidden: true),
      ChatMessage(
        role: 'model',
        text: 'Got it! I\'m ready to answer questions about ${repo.name}.',
        isHidden: true,
      ),
    ]));
  }

  Future<void> send(String text) async {
    final s = state;
    if (text.trim().isEmpty || s.isCoolingDown || s is ChatRateLimit) return;
    final userMsg = ChatMessage(role: 'user', text: text.trim());
    await _doSend([...s.messages, userMsg]);
  }

  Future<void> retry() async {
    final s = state;
    if (s is ChatError) {
      await _doSend(s.messages);
    } else if (s is ChatRateLimit) {
      _cancelRateLimit();
      await _doSend(s.pendingHistory);
    }
  }

  void dismissError() {
    final s = state;
    if (s is ChatError) {
      emit(ChatIdle(s.messages));
    } else if (s is ChatRateLimit) {
      _cancelRateLimit();
      // Drop the pending unsent user message from displayed history
      final msgs = s.pendingHistory;
      final lastUserIdx = msgs.lastIndexWhere((m) => m.role == 'user' && !m.isHidden);
      emit(ChatIdle(lastUserIdx >= 0 ? msgs.sublist(0, lastUserIdx) : msgs));
    }
  }

  Future<void> _doSend(List<ChatMessage> history) async {
    emit(ChatLoading(history));
    final result = await _useCase(history);
    switch (result) {
      case ApiSuccess(:final data):
        _analytics.logMessageSent(_repoId);
        final messages = [...history, data];
        emit(ChatIdle(messages, true));
        _startCooldown(messages);
      case ApiRateLimit():
        _analytics.logChatRateLimit(_repoId);
        _startRateLimitCountdown(history);
      case ApiFailure(:final message):
        emit(ChatError(history, message));
    }
  }

  void _startCooldown(List<ChatMessage> messages) {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(_cooldownDuration, () {
      if (!isClosed) emit(ChatIdle(messages));
    });
  }

  void _startRateLimitCountdown(List<ChatMessage> pendingHistory) {
    _cancelRateLimit();
    emit(ChatRateLimit(pendingHistory, pendingHistory, _rateLimitRetrySeconds));
    var remaining = _rateLimitRetrySeconds;
    _rateLimitTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (isClosed) { t.cancel(); return; }
      remaining--;
      if (remaining <= 0) {
        t.cancel();
        await _doSend(pendingHistory);
      } else {
        emit(ChatRateLimit(pendingHistory, pendingHistory, remaining));
      }
    });
  }

  void _cancelRateLimit() {
    _rateLimitTimer?.cancel();
    _rateLimitTimer = null;
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    _rateLimitTimer?.cancel();
    return super.close();
  }
}
