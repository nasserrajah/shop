import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../domain/entities/checkout_summary.dart';
import '../../domain/usecases/calculate_checkout_summary.dart';
import '../../domain/usecases/submit_order.dart';

final calculateCheckoutSummaryProvider = Provider<CalculateCheckoutSummary>(
  (ref) => const CalculateCheckoutSummary(),
);

final checkoutSummaryProvider = Provider<CheckoutSummary>((ref) {
  final cart = ref.watch(cartControllerProvider).valueOrNull;
  if (cart == null) return const CheckoutSummary.empty();
  return ref.watch(calculateCheckoutSummaryProvider)(cart);
});

final submitOrderProvider = Provider<SubmitOrder>((ref) {
  return SubmitOrder(
    orderRepository: ref.watch(orderRepositoryProvider),
    cartRepository: ref.watch(cartRepositoryProvider),
    calculateSummary: ref.watch(calculateCheckoutSummaryProvider),
  );
});
