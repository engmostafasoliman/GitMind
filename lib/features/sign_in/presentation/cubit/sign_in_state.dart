import '../../../profile/domain/entities/user_entity.dart';

sealed class SignInState {
  const SignInState();
}

final class SignInInitial extends SignInState {
  const SignInInitial();
}

final class SignInLoading extends SignInState {
  const SignInLoading();
}

final class SignInSuccess extends SignInState {
  final UserEntity user;
  const SignInSuccess(this.user);
}

final class SignInError extends SignInState {
  final String message;
  const SignInError(this.message);
}
