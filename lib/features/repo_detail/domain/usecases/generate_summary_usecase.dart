import '../../../../../core/result/api_result.dart';
import '../../../repo_list/domain/entities/repo_summary_entity.dart';
import '../../../repo_list/domain/repositories/repo_repository.dart';

class GenerateSummaryUseCase {
  final RepoRepository _repository;
  const GenerateSummaryUseCase(this._repository);

  Future<ApiResult<RepoSummaryEntity>> call(String repoId, {bool force = false}) =>
      _repository.generateSummary(repoId, force: force);
}
