import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/usecases/sign_in_with_github_usecase.dart';
import 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final SignInWithGitHubUseCase _useCase;
  final AnalyticsService _analytics;

  SignInCubit(this._useCase, {AnalyticsService? analytics})
      : _analytics = analytics ?? getIt<AnalyticsService>(),
        super(const SignInInitial());

  Future<void> signInWithGitHub() async {
    emit(const SignInLoading());
    final result = await _useCase();
    switch (result) {
      case ApiSuccess(:final data):
        await _analytics.logSignIn();
        emit(SignInSuccess(data));
      case ApiFailure(:final message):
        emit(SignInError(message));
      case ApiRateLimit():
        emit(const SignInError('Service temporarily unavailable. Please try again.'));
    }
  }
}
