import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../domain/usecases/sign_in_with_github_usecase.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final SignInWithGitHubUseCase _useCase;

  SignInCubit(this._useCase) : super(const SignInInitial());

  Future<void> signInWithGitHub() async {
    emit(const SignInLoading());
    final result = await _useCase();
    switch (result) {
      case ApiSuccess(:final data):
        emit(SignInSuccess(data));
      case ApiFailure(:final message):
        emit(SignInError(message));
    }
  }
}
