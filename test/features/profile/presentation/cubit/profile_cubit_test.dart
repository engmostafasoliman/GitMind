import 'package:bloc_test/bloc_test.dart';
import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/profile/domain/entities/user_entity.dart';
import 'package:chaty_ai_agent/features/profile/domain/repositories/profile_repository.dart';
import 'package:chaty_ai_agent/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:chaty_ai_agent/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:chaty_ai_agent/features/profile/presentation/cubit/profile_state.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/entities/repo_entity.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/usecases/get_repos_usecase.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/repositories/repo_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockRepoRepository extends Mock implements RepoRepository {}

const _tUser = UserEntity(
  name: 'Ada Lovelace',
  handle: 'ada',
  initials: 'AL',
  bio: '',
  location: '',
  company: '',
  joined: '',
  followers: 10,
  following: 5,
  publicRepos: 3,
  stars: 0,
);

const _ownedRepo = RepoEntity(
  id: '1',
  name: 'lovelace-engine',
  owner: 'ada',
  description: 'Analytical engine',
  language: 'Ada',
  stars: 9999,
  updatedAgo: '1d',
  license: 'MIT',
  lastCommit: 'Jan 1, 1843',
  summarized: false,
);

const _otherRepo = RepoEntity(
  id: '2',
  name: 'babbage-collab',
  owner: 'babbage',
  description: 'Diff engine',
  language: 'Haskell',
  stars: 1,
  updatedAgo: '2d',
  license: 'Apache',
  lastCommit: 'Feb 1, 1843',
  summarized: false,
);

void main() {
  late MockProfileRepository mockProfileRepo;
  late MockRepoRepository mockRepoRepo;
  late GetProfileUseCase getProfile;
  late GetReposUseCase getRepos;

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    mockRepoRepo = MockRepoRepository();
    getProfile = GetProfileUseCase(mockProfileRepo);
    getRepos = GetReposUseCase(mockRepoRepo);
  });

  ProfileCubit buildCubit() => ProfileCubit(getProfile, getRepos);

  group('load()', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] with only owned repos on success',
      build: () {
        when(() => mockProfileRepo.getProfile())
            .thenAnswer((_) async => const ApiSuccess(_tUser));
        when(() => mockRepoRepo.getRepos())
            .thenAnswer((_) async =>
                const ApiSuccess([_ownedRepo, _otherRepo]));
        return buildCubit();
      },
      act: (c) => c.load(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
      verify: (c) {
        final state = c.state as ProfileLoaded;
        expect(state.user.handle, 'ada');
        expect(state.ownedRepos.length, 1);
        expect(state.ownedRepos.first.name, 'lovelace-engine');
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when getProfile fails',
      build: () {
        when(() => mockProfileRepo.getProfile())
            .thenAnswer((_) async => const ApiFailure('Session expired'));
        when(() => mockRepoRepo.getRepos())
            .thenAnswer((_) async => const ApiSuccess([]));
        return buildCubit();
      },
      act: (c) => c.load(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
      verify: (c) {
        expect((c.state as ProfileError).message, 'Session expired');
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'emits [ProfileLoading, ProfileError] when getRepos fails',
      build: () {
        when(() => mockProfileRepo.getProfile())
            .thenAnswer((_) async => const ApiSuccess(_tUser));
        when(() => mockRepoRepo.getRepos())
            .thenAnswer((_) async => const ApiFailure('Network error'));
        return buildCubit();
      },
      act: (c) => c.load(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
      verify: (c) {
        expect((c.state as ProfileError).message, 'Network error');
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'shows empty ownedRepos list when user owns no repos',
      build: () {
        when(() => mockProfileRepo.getProfile())
            .thenAnswer((_) async => const ApiSuccess(_tUser));
        when(() => mockRepoRepo.getRepos())
            .thenAnswer((_) async => const ApiSuccess([_otherRepo]));
        return buildCubit();
      },
      act: (c) => c.load(),
      verify: (c) {
        final state = c.state as ProfileLoaded;
        expect(state.ownedRepos, isEmpty);
      },
    );
  });
}
