import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/profile/domain/entities/user_entity.dart';
import 'package:chaty_ai_agent/features/sign_in/data/datasources/firebase_auth_data_source.dart';
import 'package:chaty_ai_agent/features/sign_in/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuthDataSource extends Mock implements FirebaseAuthDataSource {}

const tUser = UserEntity(
  name: 'Mostafa',
  handle: 'engmostafasoliman',
  initials: 'M',
  avatarUrl: null,
  bio: '',
  location: '',
  company: '',
  joined: 'Joined Jan 2020',
  followers: 10,
  following: 5,
  publicRepos: 20,
  stars: 0,
);

void main() {
  late MockFirebaseAuthDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockFirebaseAuthDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('getPersistedUser() — session persistence', () {
    test('returns user and caches it when Firebase session exists', () async {
      when(() => mockDataSource.getPersistedUser())
          .thenAnswer((_) async => tUser);

      final result = await repository.getPersistedUser();

      expect(result, isNotNull);
      expect(result!.handle, 'engmostafasoliman');
      expect(repository.currentUser, tUser);
    });

    test('returns null when no Firebase session exists', () async {
      when(() => mockDataSource.getPersistedUser())
          .thenAnswer((_) async => null);

      final result = await repository.getPersistedUser();

      expect(result, isNull);
      expect(repository.currentUser, isNull);
    });

    test('returns null and clears cached user when data source throws', () async {
      when(() => mockDataSource.getPersistedUser())
          .thenAnswer((_) async => null);

      final result = await repository.getPersistedUser();

      expect(result, isNull);
      expect(repository.currentUser, isNull);
    });

    test('updates currentUser after getPersistedUser succeeds', () async {
      when(() => mockDataSource.getPersistedUser())
          .thenAnswer((_) async => tUser);

      expect(repository.currentUser, isNull);
      await repository.getPersistedUser();
      expect(repository.currentUser, tUser);
    });
  });

  group('signOut()', () {
    test('clears currentUser after sign out', () async {
      when(() => mockDataSource.getPersistedUser())
          .thenAnswer((_) async => tUser);
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      await repository.getPersistedUser();
      expect(repository.currentUser, isNotNull);

      await repository.signOut();
      expect(repository.currentUser, isNull);
    });
  });

  group('signInWithGitHub()', () {
    test('returns ApiSuccess and caches user on successful sign-in', () async {
      when(() => mockDataSource.signInWithGitHub())
          .thenAnswer((_) async => tUser);

      final result = await repository.signInWithGitHub();

      expect(result, isA<ApiSuccess<UserEntity>>());
      expect((result as ApiSuccess<UserEntity>).data.handle, 'engmostafasoliman');
      expect(repository.currentUser, tUser);
    });

    test('returns ApiFailure when sign-in throws', () async {
      when(() => mockDataSource.signInWithGitHub())
          .thenThrow(Exception('sign-in cancelled'));

      final result = await repository.signInWithGitHub();

      expect(result, isA<ApiFailure<UserEntity>>());
      expect(repository.currentUser, isNull);
    });
  });
}
