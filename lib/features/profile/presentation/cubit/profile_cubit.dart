import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/api_result.dart';
import '../../../repo_list/domain/usecases/get_repos_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final GetReposUseCase _getRepos;

  ProfileCubit(this._getProfile, this._getRepos) : super(const ProfileInitial());

  Future<void> load() async {
    emit(const ProfileLoading());

    final profileFuture = _getProfile();
    final reposFuture = _getRepos();

    final profileResult = await profileFuture;
    final reposResult = await reposFuture;

    switch (profileResult) {
      case ApiSuccess(:final data):
        final user = data;
        switch (reposResult) {
          case ApiSuccess(:final data):
            final owned =
                data.where((r) => r.owner == user.handle).toList();
            emit(ProfileLoaded(user: user, ownedRepos: owned));
          case ApiFailure(:final message):
            emit(ProfileError(message));
          case ApiRateLimit():
            emit(const ProfileError(
                'Service temporarily unavailable. Please try again.'));
        }
      case ApiFailure(:final message):
        emit(ProfileError(message));
      case ApiRateLimit():
        emit(const ProfileError(
            'Service temporarily unavailable. Please try again.'));
    }
  }
}
