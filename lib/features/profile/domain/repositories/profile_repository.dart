import '../../../../core/result/api_result.dart';
import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<ApiResult<UserEntity>> getProfile();
}
