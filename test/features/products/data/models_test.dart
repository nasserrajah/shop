import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/constants/api_constants.dart';
import 'package:shop/core/entities/payment_method.dart';
import 'package:shop/features/orders/data/models/order_model.dart';
import 'package:shop/features/orders/domain/entities/order_status.dart';
import 'package:shop/features/products/data/models/product_model.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  group('ProductModel', () {
    test('maps the API payload including name, ratings and sizes', () {
      final model = ProductModel.fromJson({
        'id': 'p1',
        'name': 'Winter Jacket',
        'price': '79.5',
        'image': '/images/jacket.png',
        'category': 'winter',
        'description': 'Warm',
        'rating': '4.7',
        'reviews': '31',
        'sizes': ['M', 'L', ''],
        'inStock': false,
      });

      expect(model.id, 'p1');
      expect(model.title, 'Winter Jacket');
      expect(model.price, 79.5);
      expect(model.image, '${ApiConstants.baseUrl}/images/jacket.png');
      expect(model.category, 'winter');
      expect(model.rating, 4.7);
      expect(model.reviews, 31);
      expect(model.sizes, ['M', 'L']);
      expect(model.inStock, isFalse);
    });

    test('falls back to safe defaults for missing fields', () {
      final model = ProductModel.fromJson({'id': 7});

      expect(model.id, '7');
      expect(model.title, 'Untitled product');
      expect(model.price, 0);
      expect(model.image, '');
      expect(model.category, 'general');
      expect(model.rating, 0);
      expect(model.reviews, 0);
      expect(model.sizes, isEmpty);
      expect(model.inStock, isTrue);
    });

    test('round-trips through JSON', () {
      final original = ProductModel.fromEntity(buildProduct());
      final restored = ProductModel.fromJson(original.toJson());

      expect(restored.toJson(), original.toJson());
    });
  });

  group('OrderModel', () {
    test('round-trips an order through JSON', () {
      final order = buildOrder(
        id: 'ORD-9',
        paymentMethod: PaymentMethod.paypal,
        deliveryTime: DateTime(2026, 4, 2, 12),
        status: OrderStatus.completed,
      );
      final model = OrderModel.fromEntity(order);
      final restored = OrderModel.fromJson(model.toJson()).toEntity();

      expect(restored, order);
      expect(restored.paymentMethod, PaymentMethod.paypal);
      expect(restored.deliveryTime, DateTime(2026, 4, 2, 12));
      expect(restored.status, OrderStatus.completed);
    });

    test('defaults unknown enums instead of throwing', () {
      final model = OrderModel.fromJson({
        'id': 'ORD-1',
        'paymentMethod': 'crypto',
        'status': 'archived',
      });

      expect(model.toEntity().paymentMethod, PaymentMethod.cash);
      expect(model.toEntity().status, OrderStatus.active);
      expect(model.toEntity().items, isEmpty);
    });
  });
}
