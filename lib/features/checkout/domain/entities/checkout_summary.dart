import 'package:equatable/equatable.dart';

class CheckoutSummary extends Equatable {
  const CheckoutSummary({
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
  });

  const CheckoutSummary.empty()
      : itemsCount = 0,
        subtotal = 0,
        discount = 0,
        delivery = 0,
        total = 0;

  final int itemsCount;
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;

  bool get isEmpty => itemsCount == 0;

  @override
  List<Object?> get props => [
        itemsCount,
        subtotal,
        discount,
        delivery,
        total,
      ];
}
