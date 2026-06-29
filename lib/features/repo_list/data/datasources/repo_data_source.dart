import '../models/repo_model.dart';
import '../../domain/entities/repo_summary_entity.dart';

abstract class RepoDataSource {
  Future<List<RepoModel>> getRepos();
  Future<RepoModel> getRepoById(String id);
  Future<RepoSummaryEntity> generateSummary(String repoId);
}
