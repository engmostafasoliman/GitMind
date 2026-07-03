import '../../../../core/result/api_result.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;
  const GetProfileUseCase(this._repository);

  Future<ApiResult<UserEntity>> call() => _repository.getProfile();
}
