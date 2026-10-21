import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/usecases/cart_usecases.dart';
import '../../domain/usecases/submit_order.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required GetCart getCart,
    required SubmitOrder submitOrder,
  })  : _getCart = getCart,
        _submitOrder = submitOrder,
        super(const CheckoutState()) {
    on<CheckoutPaymentMethodChanged>(_onPaymentMethodChanged);
    on<CheckoutSubmitted>(_onSubmitted);
  }

  final GetCart _getCart;
  final SubmitOrder _submitOrder;

  void _onPaymentMethodChanged(
    CheckoutPaymentMethodChanged event,
    Emitter<CheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        paymentMethod: event.paymentMethod,
        clearError: true,
      ),
    );
  }

  Future<void> _onSubmitted(
    CheckoutSubmitted event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state.isSubmitting) return;

    emit(
      state.copyWith(
        status: CheckoutStatus.submitting,
        clearError: true,
      ),
    );

    final cartResult = await _getCart();
    final cart = cartResult.dataOrNull;
    if (cart == null) {
      emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage:
              cartResult.failureOrNull?.message ?? 'Unable to load your cart.',
        ),
      );
      return;
    }

    final result = await _submitOrder(
      cart: cart,
      paymentMethod: state.paymentMethod,
      address: event.address,
      deliveryTime: event.deliveryTime,
    );

    result.fold(
      onSuccess: (order) => emit(
        state.copyWith(
          status: CheckoutStatus.success,
          order: order,
          clearError: true,
        ),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          status: CheckoutStatus.failure,
          errorMessage: failure.message,
        ),
      ),
    );
  }
}
