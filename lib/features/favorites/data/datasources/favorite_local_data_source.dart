import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../products/data/models/product_model.dart';

abstract class FavoriteLocalDataSource {
  Future<List<ProductModel>> fetchFavorites();

  Future<void> saveFavorites(List<ProductModel> favorites);

  Future<void> clear();
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  FavoriteLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<List<ProductModel>> fetchFavorites() async {
    final raw = _prefs.getString(AppConstants.favoritesStorageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const CacheException('Saved favorites are in an invalid format.');
      }
      return decoded
          .whereType<Map>()
          .map((item) => ProductModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to read saved favorites.');
    }
  }

  @override
  Future<void> saveFavorites(List<ProductModel> favorites) async {
    try {
      final raw = jsonEncode(favorites.map((item) => item.toJson()).toList());
      final saved = await _prefs.setString(
        AppConstants.favoritesStorageKey,
        raw,
      );
      if (!saved) {
        throw const CacheException('Unable to save your favorites.');
      }
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to save your favorites.');
    }
  }

  @override
  Future<void> clear() async {
    final removed = await _prefs.remove(AppConstants.favoritesStorageKey);
    if (!removed) {
      throw const CacheException('Unable to clear your favorites.');
    }
  }
}
