import '../../../../../core/result/api_result.dart';
import '../../../repo_list/domain/entities/repo_entity.dart';
import '../../../repo_list/domain/repositories/repo_repository.dart';

class GetRepoDetailUseCase {
  final RepoRepository _repository;
  const GetRepoDetailUseCase(this._repository);

  Future<ApiResult<RepoEntity>> call(String id) => _repository.getRepoById(id);
}
