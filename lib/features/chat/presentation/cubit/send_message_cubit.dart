import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_use_case.dart';
import 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final SendMessageUseCase _useCase;

  SendMessageCubit(this._useCase) : super(const ChatIdle());

  void initWithRepo(RepoEntity repo) {
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
    if (text.trim().isEmpty) return;
    final current = state;
    final userMsg = ChatMessage(role: 'user', text: text.trim());
    final history = [...current.messages, userMsg];
    emit(ChatLoading(history));

    final result = await _useCase(history);
    switch (result) {
      case ApiSuccess(:final data):
        emit(ChatIdle([...history, data]));
      case ApiFailure(:final message):
        emit(ChatError(history, message));
    }
  }

  void dismissError() {
    final current = state;
    if (current is! ChatError) return;
    emit(ChatIdle(current.messages));
  }
}
