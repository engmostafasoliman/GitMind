import 'package:bloc_test/bloc_test.dart';
import 'package:chaty_ai_agent/core/result/api_result.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/entities/repo_entity.dart';
import 'package:chaty_ai_agent/features/repo_list/domain/usecases/get_repos_usecase.dart';
import 'package:chaty_ai_agent/features/repo_list/presentation/cubit/repo_list_cubit.dart';
import 'package:chaty_ai_agent/features/repo_list/presentation/cubit/repo_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetReposUseCase extends Mock implements GetReposUseCase {}

const _dart = RepoEntity(
  id: '1', name: 'flutter', owner: 'google', description: 'UI toolkit',
  language: 'Dart', stars: 100, updatedAgo: '1d', license: 'BSD', lastCommit: 'today',
  summarized: false,
);
const _swift = RepoEntity(
  id: '2', name: 'swift', owner: 'apple', description: 'Swift lang',
  language: 'Swift', stars: 50, updatedAgo: '2d', license: 'Apache', lastCommit: 'yesterday',
  summarized: false,
);

void main() {
  late MockGetReposUseCase mockUseCase;
  late RepoListCubit cubit;

  setUp(() {
    mockUseCase = MockGetReposUseCase();
    cubit = RepoListCubit(mockUseCase);
  });

  tearDown(() => cubit.close());

  void givenLoadedWith(List<RepoEntity> repos) {
    when(() => mockUseCase()).thenAnswer((_) async => ApiSuccess(repos));
  }

  group('load()', () {
    blocTest<RepoListCubit, RepoListState>(
      'emits [RepoListLoading, RepoListLoaded] on success',
      build: () {
        givenLoadedWith([_dart, _swift]);
        return RepoListCubit(mockUseCase);
      },
      act: (c) => c.load(),
      expect: () => [isA<RepoListLoading>(), isA<RepoListLoaded>()],
      verify: (c) {
        final loaded = c.state as RepoListLoaded;
        expect(loaded.allRepos.length, 2);
        expect(loaded.filteredRepos.length, 2);
      },
    );

    blocTest<RepoListCubit, RepoListState>(
      'emits [RepoListLoading, RepoListError] on failure',
      build: () {
        when(() => mockUseCase()).thenAnswer((_) async => const ApiFailure('Network error'));
        return RepoListCubit(mockUseCase);
      },
      act: (c) => c.load(),
      expect: () => [isA<RepoListLoading>(), isA<RepoListError>()],
      verify: (c) {
        expect((c.state as RepoListError).message, 'Network error');
      },
    );
  });

  group('search() — debounce', () {
    test('does not update state immediately when search is called', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      final initialQuery = (cubit.state as RepoListLoaded).searchQuery;
      cubit.search('flutter');

      // State should still have empty query — debounce not fired yet
      expect((cubit.state as RepoListLoaded).searchQuery, initialQuery);
    });

    test('updates state after 300ms debounce delay', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      cubit.search('flutter');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final loaded = cubit.state as RepoListLoaded;
      expect(loaded.searchQuery, 'flutter');
      expect(loaded.filteredRepos.length, 1);
      expect(loaded.filteredRepos.first.name, 'flutter');
    });

    test('cancels previous debounce when search is called rapidly', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      cubit.search('flu');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      cubit.search('flutter');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // Only the last query should be applied
      final loaded = cubit.state as RepoListLoaded;
      expect(loaded.searchQuery, 'flutter');
    });

    test('returns all repos when search is cleared', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      cubit.search('flutter');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      cubit.search('');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final loaded = cubit.state as RepoListLoaded;
      expect(loaded.filteredRepos.length, 2);
    });

    test('does nothing when state is not RepoListLoaded', () async {
      // cubit starts as RepoListInitial — search should be a no-op
      cubit.search('flutter');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      expect(cubit.state, isA<RepoListInitial>());
    });
  });

  group('filterByLanguage()', () {
    test('filters repos by language instantly', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      cubit.filterByLanguage('Swift');

      final loaded = cubit.state as RepoListLoaded;
      expect(loaded.filteredRepos.length, 1);
      expect(loaded.filteredRepos.first.language, 'Swift');
    });

    test('"All" shows every repo', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      cubit.filterByLanguage('Swift');
      cubit.filterByLanguage('All');

      expect((cubit.state as RepoListLoaded).filteredRepos.length, 2);
    });
  });

  group('sortBy()', () {
    test('sorts by stars descending', () async {
      givenLoadedWith([_swift, _dart]); // _dart has more stars
      await cubit.load();

      cubit.sortBy(RepoSort.stars);

      final repos = (cubit.state as RepoListLoaded).filteredRepos;
      expect(repos.first.stars, greaterThan(repos.last.stars));
    });

    test('sorts by name ascending', () async {
      givenLoadedWith([_swift, _dart]);
      await cubit.load();

      cubit.sortBy(RepoSort.name);

      final repos = (cubit.state as RepoListLoaded).filteredRepos;
      expect(repos.first.name.compareTo(repos.last.name), lessThan(0));
    });
  });

  group('clearFilters()', () {
    test('resets search query and language filter', () async {
      givenLoadedWith([_dart, _swift]);
      await cubit.load();

      cubit.filterByLanguage('Dart');
      cubit.clearFilters();

      final loaded = cubit.state as RepoListLoaded;
      expect(loaded.searchQuery, '');
      expect(loaded.selectedLanguage, 'All');
      expect(loaded.filteredRepos.length, 2);
    });
  });
}
