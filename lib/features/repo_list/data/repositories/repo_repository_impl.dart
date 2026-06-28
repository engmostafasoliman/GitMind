import '../../../../core/result/api_result.dart';
import '../../domain/entities/repo_entity.dart';
import '../../domain/repositories/repo_repository.dart';
import '../datasources/repo_mock_data_source.dart';

class RepoRepositoryImpl implements RepoRepository {
  final RepoMockDataSource _dataSource;
  const RepoRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<List<RepoEntity>>> getRepos() async {
    try {
      final models = await _dataSource.getRepos();
      return ApiSuccess(models);
    } catch (e) {
      return ApiFailure('Failed to load repositories. Please try again.');
    }
  }
}
