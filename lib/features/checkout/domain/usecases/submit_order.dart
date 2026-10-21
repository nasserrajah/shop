import '../../../../core/entities/payment_method.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../../orders/domain/entities/order_status.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../entities/checkout_summary.dart';
import 'calculate_checkout_summary.dart';

/// Application service that turns a cart into a persisted order and clears
/// the cart atomically from the user's point of view.
class SubmitOrder {
  const SubmitOrder({
    required OrderRepository orderRepository,
    required CartRepository cartRepository,
    required CalculateCheckoutSummary calculateSummary,
  })  : _orderRepository = orderRepository,
        _cartRepository = cartRepository,
        _calculateSummary = calculateSummary;

  final OrderRepository _orderRepository;
  final CartRepository _cartRepository;
  final CalculateCheckoutSummary _calculateSummary;

  Future<Result<Order>> call({
    required Cart cart,
    required PaymentMethod paymentMethod,
    required String address,
    DateTime? deliveryTime,
  }) async {
    if (cart.isEmpty) {
      return const Result.failure(
        ValidationFailure('Your cart is empty. Add a product before checking out.'),
      );
    }
    if (address.trim().length < 10) {
      return const Result.failure(
        ValidationFailure('Please provide a complete delivery address.'),
      );
    }

    final CheckoutSummary summary = _calculateSummary(cart);
    final now = DateTime.now();
    final order = Order(
      id: _generateOrderId(now),
      items: cart.items
          .map(
            (item) => OrderItem(
              productId: item.product.id,
              title: item.product.title,
              image: item.product.image,
              price: item.product.price,
              quantity: item.quantity,
              size: item.size,
            ),
          )
          .toList(),
      subtotal: summary.subtotal,
      discount: summary.discount,
      delivery: summary.delivery,
      total: summary.total,
      createdAt: now,
      paymentMethod: paymentMethod,
      address: address.trim(),
      deliveryTime: deliveryTime,
      status: OrderStatus.active,
    );

    final saveResult = await _orderRepository.placeOrder(order);
    if (saveResult.isFailure) {
      return Result.failure(saveResult.failureOrNull!);
    }

    // The order is already persisted; clearing the cart is best-effort so a
    // cache hiccup never hides a successful purchase.
    await _cartRepository.clear();
    return Result.success(order);
  }

  String _generateOrderId(DateTime now) {
    return 'ORD-${now.millisecondsSinceEpoch}${now.microsecond % 1000}';
  }
}
