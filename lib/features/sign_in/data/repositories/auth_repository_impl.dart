import '../../../../core/result/api_result.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;
  UserEntity? _currentUser;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<UserEntity>> signInWithGitHub() async {
    try {
      final user = await _dataSource.signInWithGitHub();
      _currentUser = user;
      return ApiSuccess(user);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
    _currentUser = null;
  }

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity?> getPersistedUser() async {
    final user = await _dataSource.getPersistedUser();
    _currentUser = user;
    return user;
  }
}
