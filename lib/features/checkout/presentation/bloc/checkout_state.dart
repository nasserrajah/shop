import 'package:equatable/equatable.dart';

import '../../../../core/entities/payment_method.dart';
import '../../../orders/domain/entities/order.dart';

enum CheckoutStatus { idle, submitting, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.paymentMethod = PaymentMethod.card,
    this.order,
    this.errorMessage,
  });

  final CheckoutStatus status;
  final PaymentMethod paymentMethod;
  final Order? order;
  final String? errorMessage;

  bool get isSubmitting => status == CheckoutStatus.submitting;

  bool get isSuccess => status == CheckoutStatus.success;

  CheckoutState copyWith({
    CheckoutStatus? status,
    PaymentMethod? paymentMethod,
    Order? order,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      order: order ?? this.order,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, paymentMethod, order, errorMessage];
}
