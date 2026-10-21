import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> fetchItems();

  Future<void> saveItems(List<CartItemModel> items);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<List<CartItemModel>> fetchItems() async {
    final raw = _prefs.getString(AppConstants.cartStorageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const CacheException('Saved cart data is in an invalid format.');
      }
      return decoded
          .whereType<Map>()
          .map((item) => CartItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((item) => item.quantity > 0)
          .toList();
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to read your saved cart.');
    }
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    try {
      final raw = jsonEncode(items.map((item) => item.toJson()).toList());
      final saved = await _prefs.setString(AppConstants.cartStorageKey, raw);
      if (!saved) {
        throw const CacheException('Unable to save your cart.');
      }
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to save your cart.');
    }
  }
}
