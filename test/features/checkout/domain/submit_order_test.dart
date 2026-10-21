import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/entities/payment_method.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/checkout/domain/usecases/calculate_checkout_summary.dart';
import 'package:shop/features/checkout/domain/usecases/submit_order.dart';
import 'package:shop/features/orders/domain/entities/order_status.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  late FakeOrderRepository orderRepository;
  late FakeCartRepository cartRepository;
  late SubmitOrder submitOrder;

  setUp(() {
    orderRepository = FakeOrderRepository();
    cartRepository = FakeCartRepository();
    submitOrder = SubmitOrder(
      orderRepository: orderRepository,
      cartRepository: cartRepository,
      calculateSummary: const CalculateCheckoutSummary(),
    );
  });

  group('SubmitOrder', () {
    test('creates a persisted order and clears the cart', () async {
      final product = buildProduct(price: 25, sizes: const ['M']);
      cartRepository.cart = buildCart(
        items: [
          buildCartItem(product: product, quantity: 2, size: 'M'),
        ],
      );
      final deliveryTime = DateTime(2026, 2, 1, 18);

      final result = await submitOrder(
        cart: cartRepository.cart,
        paymentMethod: PaymentMethod.paypal,
        address: '  123 Main Street, New York  ',
        deliveryTime: deliveryTime,
      );

      final order = result.dataOrNull;
      expect(result.isSuccess, isTrue);
      expect(order, isNotNull);
      expect(order!.id, startsWith('ORD-'));
      expect(order.items, hasLength(1));
      expect(order.items.single.productId, 'p1');
      expect(order.items.single.quantity, 2);
      expect(order.items.single.size, 'M');
      expect(order.subtotal, 50);
      expect(order.discount, 4);
      expect(order.delivery, 2);
      expect(order.total, 48);
      expect(order.address, '123 Main Street, New York');
      expect(order.paymentMethod, PaymentMethod.paypal);
      expect(order.deliveryTime, deliveryTime);
      expect(order.status, OrderStatus.active);

      expect(orderRepository.placeCalls, 1);
      expect(orderRepository.lastPlacedOrder, order);
      expect(cartRepository.clearCalls, 1);
    });

    test('rejects an empty cart without touching the repositories', () async {
      final result = await submitOrder(
        cart: buildCart(),
        paymentMethod: PaymentMethod.card,
        address: '123 Main Street, New York',
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('empty'));
      expect(orderRepository.placeCalls, 0);
      expect(cartRepository.clearCalls, 0);
    });

    test('rejects an incomplete delivery address', () async {
      final cart = buildCart(items: [buildCartItem()]);

      final result = await submitOrder(
        cart: cart,
        paymentMethod: PaymentMethod.cash,
        address: '   Short  ',
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('delivery address'));
      expect(orderRepository.placeCalls, 0);
      expect(cartRepository.clearCalls, 0);
    });

    test('does not clear the cart when saving the order fails', () async {
      final failure = ServerFailure('Could not save the order');
      orderRepository.placeFailure = failure;

      final result = await submitOrder(
        cart: buildCart(items: [buildCartItem()]),
        paymentMethod: PaymentMethod.card,
        address: '123 Main Street, New York',
      );

      expect(result.failureOrNull, same(failure));
      expect(cartRepository.clearCalls, 0);
    });

    test('still succeeds when clearing the cart fails after persistence', () async {
      cartRepository.mutationFailure = const CacheFailure('Cache unavailable');

      final result = await submitOrder(
        cart: buildCart(items: [buildCartItem()]),
        paymentMethod: PaymentMethod.card,
        address: '123 Main Street, New York',
      );

      expect(result.isSuccess, isTrue);
      expect(orderRepository.placeCalls, 1);
      expect(cartRepository.clearCalls, 1);
    });
  });
}
