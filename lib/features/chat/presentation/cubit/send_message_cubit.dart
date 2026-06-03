import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_message_use_case.dart';
import 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  final SendMessageUseCase _useCase;

  SendMessageCubit(this._useCase) : super(const SendMessageInitial());

  Future<void> sendMessage(List<ChatMessage> messages) async {
    emit(const SendMessageLoading());

    final result = await _useCase(messages);

    switch (result) {
      case ApiSuccess(:final data):
        emit(SendMessageSuccess(data));
      case ApiFailure(:final message):
        emit(SendMessageFailure(message));
    }
  }
}
