import '../repositories/repo_repository.dart';

class ClearSummariesUseCase {
  final RepoRepository _repo;
  const ClearSummariesUseCase(this._repo);

  Future<void> call() => _repo.clearSummaries();
}
