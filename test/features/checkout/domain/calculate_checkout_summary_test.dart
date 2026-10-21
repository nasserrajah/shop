import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/constants/app_constants.dart';
import 'package:shop/features/checkout/domain/usecases/calculate_checkout_summary.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  const calculate = CalculateCheckoutSummary();

  group('CalculateCheckoutSummary', () {
    test('returns an empty summary for an empty cart', () {
      final summary = calculate(buildCart());

      expect(summary.isEmpty, isTrue);
      expect(summary.itemsCount, 0);
      expect(summary.subtotal, 0);
      expect(summary.discount, 0);
      expect(summary.delivery, 0);
      expect(summary.total, 0);
    });

    test('applies the fixed discount and delivery fee', () {
      final cart = buildCart(
        items: [
          buildCartItem(product: buildProduct(price: 30), quantity: 2),
        ],
      );

      final summary = calculate(cart);

      expect(summary.itemsCount, 2);
      expect(summary.subtotal, 60);
      expect(summary.discount, AppConstants.discountAmount);
      expect(summary.delivery, AppConstants.deliveryFee);
      expect(summary.total, 60 - 4 + 2);
    });

    test('discount never exceeds the subtotal', () {
      final cart = buildCart(
        items: [
          buildCartItem(product: buildProduct(price: 3), quantity: 1),
        ],
      );

      final summary = calculate(cart);

      expect(summary.subtotal, 3);
      expect(summary.discount, 3);
      expect(summary.total, 2);
    });

    test('counts quantities across multiple lines', () {
      final cart = buildCart(
        items: [
          buildCartItem(product: buildProduct(id: 'a', price: 10), quantity: 2),
          buildCartItem(product: buildProduct(id: 'b', price: 5.5), quantity: 3),
        ],
      );

      final summary = calculate(cart);

      expect(summary.itemsCount, 5);
      expect(summary.subtotal, closeTo(36.5, 0.0001));
      expect(summary.total, closeTo(34.5, 0.0001));
    });
  });
}
