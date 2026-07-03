import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/profile/data/datasources/profile_data_source.dart';
import 'package:chaty_ai_agent/features/profile/data/models/user_model.dart';
import 'package:chaty_ai_agent/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:chaty_ai_agent/features/profile/domain/entities/user_entity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileDataSource extends Mock implements ProfileDataSource {}
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

const _tUser = UserModel(
  name: 'Ada Lovelace',
  handle: 'ada',
  initials: 'AL',
  avatarUrl: 'https://example.com/avatar.png',
  bio: 'Mathematician',
  location: 'London',
  company: 'babbage',
  joined: 'Joined Dec 1815',
  followers: 9999,
  following: 1,
  publicRepos: 42,
  stars: 0,
);

void main() {
  late MockProfileDataSource mockDataSource;
  late MockFlutterSecureStorage mockStorage;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockProfileDataSource();
    mockStorage = MockFlutterSecureStorage();
    repository = ProfileRepositoryImpl(mockDataSource, storage: mockStorage);
  });

  group('getProfile()', () {
    test('returns ApiSuccess with user when token exists and API succeeds',
        () async {
      when(() => mockStorage.read(key: 'github_access_token'))
          .thenAnswer((_) async => 'token_abc');
      when(() => mockDataSource.getProfile('token_abc'))
          .thenAnswer((_) async => _tUser);

      final result = await repository.getProfile();

      expect(result, isA<ApiSuccess<UserEntity>>());
      final user = (result as ApiSuccess<UserEntity>).data;
      expect(user.handle, 'ada');
      expect(user.name, 'Ada Lovelace');
    });

    test('returns ApiFailure when no token is stored', () async {
      when(() => mockStorage.read(key: 'github_access_token'))
          .thenAnswer((_) async => null);

      final result = await repository.getProfile();

      expect(result, isA<ApiFailure<UserEntity>>());
      expect((result as ApiFailure<UserEntity>).message, contains('Not signed in'));
    });

    test('returns ApiFailure with session-expired message on Unauthorized',
        () async {
      when(() => mockStorage.read(key: 'github_access_token'))
          .thenAnswer((_) async => 'stale_token');
      when(() => mockDataSource.getProfile('stale_token'))
          .thenThrow(Exception('Unauthorized'));

      final result = await repository.getProfile();

      expect(result, isA<ApiFailure<UserEntity>>());
      expect((result as ApiFailure<UserEntity>).message,
          contains('Session expired'));
    });

    test('returns generic ApiFailure on unexpected error', () async {
      when(() => mockStorage.read(key: 'github_access_token'))
          .thenAnswer((_) async => 'token_abc');
      when(() => mockDataSource.getProfile(any()))
          .thenThrow(Exception('500 Internal Server Error'));

      final result = await repository.getProfile();

      expect(result, isA<ApiFailure<UserEntity>>());
      expect((result as ApiFailure<UserEntity>).message,
          contains('Could not load profile'));
    });
  });
}
