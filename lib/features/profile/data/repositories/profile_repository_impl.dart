import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/result/api_result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final FlutterSecureStorage _storage;

  ProfileRepositoryImpl(this._dataSource,
      {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<ApiResult<UserEntity>> getProfile() async {
    try {
      final token = await _storage.read(key: 'github_access_token');
      if (token == null) {
        return const ApiFailure('Not signed in. Please sign in again.');
      }
      final user = await _dataSource.getProfile(token);
      return ApiSuccess(user);
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('Unauthorized')) {
        return const ApiFailure('Session expired. Please sign in again.');
      }
      if (msg.contains('No address associated')) {
        return const ApiFailure(
            'No internet connection. Please check your network.');
      }
      return const ApiFailure('Could not load profile. Please try again.');
    }
  }
}
