import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required ProfileLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final ProfileLocalDataSource _localDataSource;

  @override
  Future<Result<UserProfile>> getProfile() async {
    try {
      final stored = await _localDataSource.fetchProfile();
      return Result.success(stored ?? UserProfileModel.fromEntity(UserProfile.demo()));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _localDataSource.saveProfile(model);
      return Result.success(model);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<UserProfile>> signOut() async {
    try {
      final guest = UserProfileModel.fromEntity(UserProfile.guest());
      await _localDataSource.saveProfile(guest);
      return Result.success(guest);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }
}
