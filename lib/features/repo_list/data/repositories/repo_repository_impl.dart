import '../../../../core/error/app_exception.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/repo_entity.dart';
import '../../domain/entities/repo_summary_entity.dart';
import '../../domain/repositories/repo_repository.dart';
import '../datasources/repo_data_source.dart';

class RepoRepositoryImpl implements RepoRepository {
  final RepoDataSource _dataSource;
  const RepoRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<List<RepoEntity>>> getRepos() async {
    try {
      return ApiSuccess(await _dataSource.getRepos());
    } catch (e) {
      return const ApiFailure('Failed to load repositories. Please try again.');
    }
  }

  @override
  Future<ApiResult<RepoEntity>> getRepoById(String id) async {
    try {
      return ApiSuccess(await _dataSource.getRepoById(id));
    } catch (e) {
      return const ApiFailure('Repository not found.');
    }
  }

  @override
  Future<ApiResult<RepoSummaryEntity>> generateSummary(String repoId, {bool force = false}) async {
    try {
      return ApiSuccess(await _dataSource.generateSummary(repoId, force: force));
    } on RateLimitException {
      return const ApiRateLimit();
    } catch (e) {
      return const ApiFailure('Failed to generate summary. Please try again.');
    }
  }

  @override
  Future<void> clearSummaries() => _dataSource.clearSummaries();
}
