import '../../../../core/result/api_result.dart';
import '../entities/repo_entity.dart';
import '../repositories/repo_repository.dart';

class GetReposUseCase {
  final RepoRepository _repository;
  const GetReposUseCase(this._repository);

  Future<ApiResult<List<RepoEntity>>> call() => _repository.getRepos();
}
