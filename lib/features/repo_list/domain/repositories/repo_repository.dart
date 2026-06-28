import '../../../../core/result/api_result.dart';
import '../entities/repo_entity.dart';

abstract class RepoRepository {
  Future<ApiResult<List<RepoEntity>>> getRepos();
}
