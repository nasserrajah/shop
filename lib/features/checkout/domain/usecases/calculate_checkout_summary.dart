import '../../../../core/constants/app_constants.dart';
import '../../../cart/domain/entities/cart.dart';
import '../entities/checkout_summary.dart';

class CalculateCheckoutSummary {
  const CalculateCheckoutSummary();

  CheckoutSummary call(Cart cart) {
    if (cart.isEmpty) return const CheckoutSummary.empty();

    final subtotal = cart.subtotal;
    final discount = subtotal < AppConstants.discountAmount
        ? subtotal
        : AppConstants.discountAmount;
    final delivery = AppConstants.deliveryFee;
    final total = (subtotal - discount + delivery).clamp(0, double.infinity);

    return CheckoutSummary(
      itemsCount: cart.itemCount,
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      total: total.toDouble(),
    );
  }
}
