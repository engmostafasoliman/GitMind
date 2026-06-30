import '../../../../core/result/api_result.dart';
import '../entities/repo_entity.dart';
import '../entities/repo_summary_entity.dart';

abstract class RepoRepository {
  Future<ApiResult<List<RepoEntity>>> getRepos();
  Future<ApiResult<RepoEntity>> getRepoById(String id);
  Future<ApiResult<RepoSummaryEntity>> generateSummary(String repoId, {bool force = false});
  Future<void> clearSummaries();
}
