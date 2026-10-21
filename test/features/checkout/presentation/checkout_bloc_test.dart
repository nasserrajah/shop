import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/entities/payment_method.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shop/features/checkout/domain/usecases/calculate_checkout_summary.dart';
import 'package:shop/features/checkout/domain/usecases/submit_order.dart';
import 'package:shop/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:shop/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:shop/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:shop/features/orders/domain/entities/order_status.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  late FakeCartRepository cartRepository;
  late FakeOrderRepository orderRepository;
  late CheckoutBloc bloc;

  setUp(() {
    cartRepository = FakeCartRepository(
      cart: buildCart(items: [buildCartItem(product: buildProduct(), quantity: 2)]),
    );
    orderRepository = FakeOrderRepository();
    bloc = CheckoutBloc(
      getCart: GetCart(cartRepository),
      submitOrder: SubmitOrder(
        orderRepository: orderRepository,
        cartRepository: cartRepository,
        calculateSummary: const CalculateCheckoutSummary(),
      ),
    );
  });

  tearDown(() => bloc.close());

  group('CheckoutBloc', () {
    test('starts idle with the default payment method', () {
      expect(bloc.state.status, CheckoutStatus.idle);
      expect(bloc.state.paymentMethod, PaymentMethod.card);
      expect(bloc.state.order, isNull);
      expect(bloc.state.errorMessage, isNull);
    });

    test('changes the payment method', () async {
      final changed = bloc.stream.firstWhere(
        (state) => state.paymentMethod == PaymentMethod.paypal,
      );
      bloc.add(const CheckoutPaymentMethodChanged(PaymentMethod.paypal));

      final state = await changed;

      expect(state.paymentMethod, PaymentMethod.paypal);
      expect(state.status, CheckoutStatus.idle);
    });

    test('submits an order, emits success and clears the cart', () async {
      final success = bloc.stream.firstWhere((state) => state.isSuccess);

      bloc.add(
        const CheckoutSubmitted(address: '123 Main Street, New York'),
      );
      final state = await success;

      expect(state.order, isNotNull);
      expect(state.order!.id, startsWith('ORD-'));
      expect(state.order!.total, closeTo(97.98, 0.0001));
      expect(state.order!.status, OrderStatus.active);
      expect(orderRepository.placeCalls, 1);
      expect(cartRepository.clearCalls, 1);
      expect(state.errorMessage, isNull);
    });

    test('exposes a submitting state while the order is in flight', () async {
      final gate = Completer<void>();
      orderRepository.placeGate = gate;

      final submitting = bloc.stream.firstWhere((state) => state.isSubmitting);
      bloc.add(const CheckoutSubmitted(address: '123 Main Street, New York'));
      final inFlight = await submitting;

      expect(inFlight.isSubmitting, isTrue);
      expect(inFlight.order, isNull);

      final success = bloc.stream.firstWhere((state) => state.isSuccess);
      gate.complete();
      await success;

      expect(bloc.state.isSuccess, isTrue);
    });

    test('ignores extra submissions while the first one runs', () async {
      final gate = Completer<void>();
      orderRepository.placeGate = gate;

      bloc.add(const CheckoutSubmitted(address: '123 Main Street, New York'));
      await bloc.stream.firstWhere((state) => state.isSubmitting);

      bloc.add(const CheckoutSubmitted(address: '123 Main Street, New York'));
      await Future<void>.delayed(Duration.zero);

      expect(orderRepository.placeCalls, 1);

      final success = bloc.stream.firstWhere((state) => state.isSuccess);
      gate.complete();
      await success;
    });

    test('fails when the cart is empty', () async {
      cartRepository.cart = buildCart();

      final failed = bloc.stream.firstWhere(
        (state) => state.status == CheckoutStatus.failure,
      );
      bloc.add(const CheckoutSubmitted(address: '123 Main Street, New York'));
      final state = await failed;

      expect(state.errorMessage, contains('empty'));
      expect(orderRepository.placeCalls, 0);
    });

    test('fails when the address is incomplete', () async {
      final failed = bloc.stream.firstWhere(
        (state) => state.status == CheckoutStatus.failure,
      );
      bloc.add(const CheckoutSubmitted(address: 'Short'));
      final state = await failed;

      expect(state.errorMessage, contains('delivery address'));
      expect(orderRepository.placeCalls, 0);
      expect(cartRepository.clearCalls, 0);
    });

    test('fails when the cart cannot be loaded', () async {
      cartRepository.loadFailure = const CacheFailure('Cart unavailable');

      final failed = bloc.stream.firstWhere(
        (state) => state.status == CheckoutStatus.failure,
      );
      bloc.add(const CheckoutSubmitted(address: '123 Main Street, New York'));
      final state = await failed;

      expect(state.errorMessage, 'Cart unavailable');
      expect(orderRepository.placeCalls, 0);
    });

    test('fails when the order cannot be saved and keeps the cart', () async {
      orderRepository.placeFailure = const ServerFailure('Payment declined');

      final failed = bloc.stream.firstWhere(
        (state) => state.status == CheckoutStatus.failure,
      );
      bloc.add(const CheckoutSubmitted(address: '123 Main Street, New York'));
      final state = await failed;

      expect(state.errorMessage, 'Payment declined');
      expect(state.order, isNull);
      expect(cartRepository.clearCalls, 0);
    });
  });
}
