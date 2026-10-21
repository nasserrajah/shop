import '../../../../core/result/result.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile>> call() => _repository.getProfile();
}

class UpdateProfile {
  const UpdateProfile(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile>> call(UserProfile profile) {
    return _repository.updateProfile(profile);
  }
}

class SignOut {
  const SignOut(this._repository);

  final ProfileRepository _repository;

  Future<Result<UserProfile>> call() => _repository.signOut();
}
