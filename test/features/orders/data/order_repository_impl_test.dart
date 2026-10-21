import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/constants/app_constants.dart';
import 'package:shop/core/entities/payment_method.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/orders/data/datasources/order_local_data_source.dart';
import 'package:shop/features/orders/data/repositories/order_repository_impl.dart';
import 'package:shop/features/orders/domain/entities/order_status.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OrderRepositoryImpl repository;

  group('OrderRepositoryImpl', () {
    setUp(() async {
      final prefs = await createTestPreferences();
      repository = OrderRepositoryImpl(
        localDataSource: OrderLocalDataSourceImpl(prefs: prefs),
      );
    });

    test('starts with no orders', () async {
      final result = await repository.getOrders();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('persists a placed order with all of its details', () async {
      final deliveryTime = DateTime(2026, 3, 1, 17, 30);
      final order = buildOrder(
        id: 'ORD-123',
        paymentMethod: PaymentMethod.paypal,
        deliveryTime: deliveryTime,
        status: OrderStatus.active,
      );

      final placed = await repository.placeOrder(order);

      expect(placed.dataOrNull, order);
      final stored = await repository.getOrders();
      expect(stored.dataOrNull, hasLength(1));
      expect(stored.dataOrNull!.single.id, 'ORD-123');
      expect(stored.dataOrNull!.single.paymentMethod, PaymentMethod.paypal);
      expect(stored.dataOrNull!.single.deliveryTime, deliveryTime);
      expect(stored.dataOrNull!.single.items.single.title, 'Running Shoes');
      expect(stored.dataOrNull!.single.total, 47.99);
    });

    test('returns orders newest first', () async {
      await repository.placeOrder(
        buildOrder(id: 'OLD', createdAt: DateTime(2026, 1, 1)),
      );
      await repository.placeOrder(
        buildOrder(id: 'NEW', createdAt: DateTime(2026, 2, 1)),
      );

      final result = await repository.getOrders();

      expect(result.dataOrNull!.map((order) => order.id), ['NEW', 'OLD']);
    });

    test('updates an order status and persists the change', () async {
      await repository.placeOrder(buildOrder(id: 'ORD-1'));

      final updated = await repository.updateStatus(
        'ORD-1',
        OrderStatus.completed,
      );

      expect(updated.dataOrNull!.status, OrderStatus.completed);
      final stored = await repository.getOrders();
      expect(stored.dataOrNull!.single.status, OrderStatus.completed);
    });

    test('returns NotFoundFailure for an unknown order', () async {
      final result = await repository.updateStatus(
        'missing',
        OrderStatus.cancelled,
      );

      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('maps corrupted local storage to a CacheFailure', () async {
      final prefs = await createTestPreferences({
        AppConstants.ordersStorageKey: '<<not-json>>',
      });
      final corrupted = OrderRepositoryImpl(
        localDataSource: OrderLocalDataSourceImpl(prefs: prefs),
      );

      final result = await corrupted.getOrders();

      expect(result.failureOrNull, isA<CacheFailure>());
      expect(result.failureOrNull!.message, contains('Unable to read'));
    });
  });
}
