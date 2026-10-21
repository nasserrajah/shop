import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/orders/domain/entities/order_status.dart';
import 'package:shop/features/orders/domain/usecases/order_usecases.dart';
import 'package:shop/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:shop/features/orders/presentation/bloc/orders_event.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  OrdersBloc buildBloc(FakeOrderRepository repository) {
    return OrdersBloc(
      getOrders: GetOrders(repository),
      updateOrderStatus: UpdateOrderStatus(repository),
    );
  }

  group('OrdersBloc', () {
    test('loads orders and stops loading', () async {
      final orders = [
        buildOrder(id: 'ORD-1'),
        buildOrder(id: 'ORD-2', status: OrderStatus.completed),
      ];
      final bloc = buildBloc(FakeOrderRepository(orders: orders));
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere((state) => !state.isLoading);
      bloc.add(const LoadOrdersEvent());
      final state = await loaded;

      expect(state.orders, orders);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.hasOrders, isTrue);
      expect(state.byStatus(OrderStatus.active).map((order) => order.id), ['ORD-1']);
    });

    test('reports a load failure', () async {
      final bloc = buildBloc(
        FakeOrderRepository(getFailure: const CacheFailure('Cannot read orders')),
      );
      addTearDown(bloc.close);

      final failed = bloc.stream.firstWhere((state) => state.hasError);
      bloc.add(const LoadOrdersEvent());
      final state = await failed;

      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'Cannot read orders');
      expect(state.orders, isEmpty);
    });

    test('cancels an order', () async {
      final repository = FakeOrderRepository(orders: [buildOrder(id: 'ORD-1')]);
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere((state) => !state.isLoading);
      bloc.add(const LoadOrdersEvent());
      await loaded;

      final cancelled = bloc.stream.firstWhere(
        (state) => state.orders.single.status == OrderStatus.cancelled,
      );
      bloc.add(const CancelOrderEvent('ORD-1'));
      final state = await cancelled;

      expect(state.orders.single.status, OrderStatus.cancelled);
      expect(state.pendingOrderId, isNull);
      expect(repository.updateCalls, 1);
    });

    test('completes an order', () async {
      final repository = FakeOrderRepository(orders: [buildOrder(id: 'ORD-1')]);
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere((state) => !state.isLoading);
      bloc.add(const LoadOrdersEvent());
      await loaded;

      final completed = bloc.stream.firstWhere(
        (state) => state.orders.single.status == OrderStatus.completed,
      );
      bloc.add(const CompleteOrderEvent('ORD-1'));
      final state = await completed;

      expect(state.orders.single.status, OrderStatus.completed);
      expect(state.pendingOrderId, isNull);
    });

    test('surfaces a status update failure without changing the order', () async {
      final repository = FakeOrderRepository(orders: [buildOrder(id: 'ORD-1')]);
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere((state) => !state.isLoading);
      bloc.add(const LoadOrdersEvent());
      await loaded;

      repository.updateFailure = const NotFoundFailure('Order gone');
      final failed = bloc.stream.firstWhere((state) => state.hasError);
      bloc.add(const CancelOrderEvent('ORD-1'));
      final state = await failed;

      expect(state.errorMessage, 'Order gone');
      expect(state.orders.single.status, OrderStatus.active);
      expect(state.pendingOrderId, isNull);
    });
  });
}
