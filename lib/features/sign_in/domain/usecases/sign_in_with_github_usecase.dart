import '../../../../core/result/api_result.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGitHubUseCase {
  final AuthRepository _repository;
  SignInWithGitHubUseCase(this._repository);

  Future<ApiResult<UserEntity>> call() => _repository.signInWithGitHub();
}
