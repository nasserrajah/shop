import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel?> fetchProfile();

  Future<void> saveProfile(UserProfileModel profile);

  Future<void> clearProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<UserProfileModel?> fetchProfile() async {
    final raw = _prefs.getString(AppConstants.profileStorageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const CacheException('Saved profile data is invalid.');
      }
      return UserProfileModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to read your saved profile.');
    }
  }

  @override
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      final raw = jsonEncode(profile.toJson());
      final saved = await _prefs.setString(
        AppConstants.profileStorageKey,
        raw,
      );
      if (!saved) {
        throw const CacheException('Unable to save your profile.');
      }
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to save your profile.');
    }
  }

  @override
  Future<void> clearProfile() async {
    final removed = await _prefs.remove(AppConstants.profileStorageKey);
    if (!removed) {
      throw const CacheException('Unable to sign out right now.');
    }
  }
}
