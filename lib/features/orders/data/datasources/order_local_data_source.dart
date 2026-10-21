import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/order_model.dart';

abstract class OrderLocalDataSource {
  Future<List<OrderModel>> fetchOrders();

  Future<void> saveOrders(List<OrderModel> orders);
}

class OrderLocalDataSourceImpl implements OrderLocalDataSource {
  OrderLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<List<OrderModel>> fetchOrders() async {
    final raw = _prefs.getString(AppConstants.ordersStorageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const CacheException('Saved orders are in an invalid format.');
      }
      return decoded
          .whereType<Map>()
          .map((item) => OrderModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to read your saved orders.');
    }
  }

  @override
  Future<void> saveOrders(List<OrderModel> orders) async {
    try {
      final raw = jsonEncode(orders.map((order) => order.toJson()).toList());
      final saved = await _prefs.setString(AppConstants.ordersStorageKey, raw);
      if (!saved) {
        throw const CacheException('Unable to save your orders.');
      }
    } on CacheException {
      rethrow;
    } on Object {
      throw const CacheException('Unable to save your orders.');
    }
  }
}
