import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/repo_entity.dart';
import '../../domain/entities/repo_summary_entity.dart';
import '../../domain/usecases/get_repos_usecase.dart';
import 'repo_list_state.dart';

class RepoListCubit extends Cubit<RepoListState> {
  final GetReposUseCase _getRepos;

  RepoListCubit(this._getRepos) : super(const RepoListInitial());

  Future<void> load() async {
    emit(const RepoListLoading());
    final result = await _getRepos();
    switch (result) {
      case ApiSuccess(:final data):
        emit(_buildLoaded(
          allRepos: data,
          searchQuery: '',
          selectedLanguage: 'All',
          sort: RepoSort.updated,
        ));
      case ApiFailure(:final message):
        emit(RepoListError(message));
      case ApiRateLimit():
        emit(const RepoListError('Service temporarily unavailable. Please try again.'));
    }
  }

  void search(String query) {
    final current = state;
    if (current is! RepoListLoaded) return;
    final next = current.copyWith(searchQuery: query);
    emit(_applyFilters(next));
  }

  void filterByLanguage(String language) {
    final current = state;
    if (current is! RepoListLoaded) return;
    final next = current.copyWith(selectedLanguage: language);
    emit(_applyFilters(next));
  }

  void sortBy(RepoSort sort) {
    final current = state;
    if (current is! RepoListLoaded) return;
    final next = current.copyWith(sort: sort);
    emit(_applyFilters(next));
  }

  void clearFilters() {
    final current = state;
    if (current is! RepoListLoaded) return;
    final next = current.copyWith(searchQuery: '', selectedLanguage: 'All');
    emit(_applyFilters(next));
  }

  void markSummarized(String repoId, RepoSummaryEntity summary) {
    final current = state;
    if (current is! RepoListLoaded) return;
    final updated = current.allRepos
        .map((r) => r.id == repoId ? r.withSummary(summary) : r)
        .toList();
    emit(_applyFilters(current.copyWith(allRepos: updated)));
  }

  void clearAllSummarized() {
    final current = state;
    if (current is! RepoListLoaded) return;
    final updated = current.allRepos
        .map((r) => RepoEntity(
              id: r.id,
              name: r.name,
              owner: r.owner,
              description: r.description,
              language: r.language,
              stars: r.stars,
              updatedAgo: r.updatedAgo,
              license: r.license,
              lastCommit: r.lastCommit,
              summarized: false,
            ))
        .toList();
    emit(_applyFilters(current.copyWith(allRepos: updated)));
  }

  RepoListLoaded _applyFilters(RepoListLoaded state) {
    final q = state.searchQuery.toLowerCase();
    var filtered = state.allRepos.where((r) {
      final matchesText = q.isEmpty ||
          r.name.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
      final matchesLang =
          state.selectedLanguage == 'All' || r.language == state.selectedLanguage;
      return matchesText && matchesLang;
    }).toList();

    switch (state.sort) {
      case RepoSort.stars:
        filtered.sort((a, b) => b.stars.compareTo(a.stars));
      case RepoSort.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case RepoSort.updated:
        break;
    }

    return state.copyWith(filteredRepos: filtered);
  }

  RepoListLoaded _buildLoaded({
    required List<RepoEntity> allRepos,
    required String searchQuery,
    required String selectedLanguage,
    required RepoSort sort,
  }) =>
      _applyFilters(RepoListLoaded(
        allRepos: allRepos,
        filteredRepos: allRepos,
        searchQuery: searchQuery,
        selectedLanguage: selectedLanguage,
        sort: sort,
      ));
}
