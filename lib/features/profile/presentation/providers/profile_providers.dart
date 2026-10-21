import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/result/result.dart';
import '../../data/datasources/profile_local_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

final profileLocalDataSourceProvider = Provider<ProfileLocalDataSource>((ref) {
  return ProfileLocalDataSourceImpl(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    localDataSource: ref.watch(profileLocalDataSourceProvider),
  );
});

final getProfileProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.watch(profileRepositoryProvider));
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(profileRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(profileRepositoryProvider));
});

class ProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final result = await ref.watch(getProfileProvider)();
    return result.fold(
      onSuccess: (profile) => profile,
      onFailure: (failure) => throw failure,
    );
  }

  Future<Result<UserProfile>> save(UserProfile profile) async {
    final result = await ref.read(updateProfileProvider)(profile);
    result.fold(
      onSuccess: (updated) => state = AsyncData(updated),
      onFailure: (_) {},
    );
    return result;
  }

  Future<Result<UserProfile>> signOut() async {
    final result = await ref.read(signOutProvider)();
    result.fold(
      onSuccess: (profile) => state = AsyncData(profile),
      onFailure: (_) {},
    );
    return result;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile>(
  ProfileController.new,
);

final profileProvider = profileControllerProvider;
