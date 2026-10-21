import 'package:equatable/equatable.dart';

import '../../../../core/entities/payment_method.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutPaymentMethodChanged extends CheckoutEvent {
  const CheckoutPaymentMethodChanged(this.paymentMethod);

  final PaymentMethod paymentMethod;

  @override
  List<Object?> get props => [paymentMethod];
}

class CheckoutSubmitted extends CheckoutEvent {
  const CheckoutSubmitted({
    required this.address,
    this.deliveryTime,
  });

  final String address;
  final DateTime? deliveryTime;

  @override
  List<Object?> get props => [address, deliveryTime];
}
