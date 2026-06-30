import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/result/api_result.dart';
import '../../../repo_list/domain/usecases/get_repos_usecase.dart';
import '../../domain/entities/user_entity.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetReposUseCase _getRepos;
  final UserEntity _user;

  ProfileCubit(this._getRepos, this._user) : super(const ProfileInitial());

  Future<void> load() async {
    emit(const ProfileLoading());
    final result = await _getRepos();
    switch (result) {
      case ApiSuccess(:final data):
        final owned = data
            .where((r) => r.owner == _user.company || r.owner == _user.handle)
            .toList();
        emit(ProfileLoaded(user: _user, ownedRepos: owned));
      case ApiFailure(:final message):
        emit(ProfileError(message));
      case ApiRateLimit():
        emit(const ProfileError('Service temporarily unavailable. Please try again.'));
    }
  }
}
