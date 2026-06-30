import '../../../repo_list/domain/entities/repo_entity.dart';

sealed class RepoDetailState {
  const RepoDetailState();
}

final class RepoDetailInitial extends RepoDetailState {
  const RepoDetailInitial();
}

final class RepoDetailLoading extends RepoDetailState {
  const RepoDetailLoading();
}

final class RepoDetailLoaded extends RepoDetailState {
  final RepoEntity repo;
  const RepoDetailLoaded(this.repo);
}

final class RepoDetailGenerating extends RepoDetailState {
  final RepoEntity repo;
  const RepoDetailGenerating(this.repo);
}

final class RepoDetailError extends RepoDetailState {
  final String message;
  const RepoDetailError(this.message);
}

final class RepoDetailRateLimit extends RepoDetailState {
  final RepoEntity repo;
  final int secondsRemaining;
  const RepoDetailRateLimit(this.repo, this.secondsRemaining);
}
