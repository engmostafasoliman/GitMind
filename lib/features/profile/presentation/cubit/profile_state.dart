import '../../../repo_list/domain/entities/repo_entity.dart';
import '../../domain/entities/user_entity.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final List<RepoEntity> ownedRepos;
  const ProfileLoaded({required this.user, required this.ownedRepos});
}

final class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
