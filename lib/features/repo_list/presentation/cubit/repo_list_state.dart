import '../../domain/entities/repo_entity.dart';

enum RepoSort { updated, stars, name }

sealed class RepoListState {
  const RepoListState();
}

final class RepoListInitial extends RepoListState {
  const RepoListInitial();
}

final class RepoListLoading extends RepoListState {
  const RepoListLoading();
}

final class RepoListLoaded extends RepoListState {
  final List<RepoEntity> allRepos;
  final List<RepoEntity> filteredRepos;
  final String searchQuery;
  final String selectedLanguage;
  final RepoSort sort;

  const RepoListLoaded({
    required this.allRepos,
    required this.filteredRepos,
    required this.searchQuery,
    required this.selectedLanguage,
    required this.sort,
  });

  List<String> get languages =>
      ['All', ...{...allRepos.map((r) => r.language)}];

  RepoListLoaded copyWith({
    List<RepoEntity>? allRepos,
    List<RepoEntity>? filteredRepos,
    String? searchQuery,
    String? selectedLanguage,
    RepoSort? sort,
  }) =>
      RepoListLoaded(
        allRepos: allRepos ?? this.allRepos,
        filteredRepos: filteredRepos ?? this.filteredRepos,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedLanguage: selectedLanguage ?? this.selectedLanguage,
        sort: sort ?? this.sort,
      );
}

final class RepoListError extends RepoListState {
  final String message;
  const RepoListError(this.message);
}
