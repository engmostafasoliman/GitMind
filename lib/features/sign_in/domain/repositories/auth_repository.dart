import '../../../../core/result/api_result.dart';
import '../../../profile/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<UserEntity>> signInWithGitHub();
  Future<void> signOut();
  UserEntity? get currentUser;
}
