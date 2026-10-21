import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_status.dart';
import '../../domain/usecases/order_usecases.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({
    required GetOrders getOrders,
    required UpdateOrderStatus updateOrderStatus,
  })  : _getOrders = getOrders,
        _updateOrderStatus = updateOrderStatus,
        super(const OrdersState()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<CancelOrderEvent>(_onCancelOrder);
    on<CompleteOrderEvent>(_onCompleteOrder);
  }

  final GetOrders _getOrders;
  final UpdateOrderStatus _updateOrderStatus;

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getOrders();
    result.fold(
      onSuccess: (orders) => emit(
        state.copyWith(
          orders: orders,
          isLoading: false,
          clearError: true,
        ),
      ),
      onFailure: (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
      ),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrdersState> emit,
  ) {
    return _updateStatus(event.orderId, OrderStatus.cancelled, emit);
  }

  Future<void> _onCompleteOrder(
    CompleteOrderEvent event,
    Emitter<OrdersState> emit,
  ) {
    return _updateStatus(event.orderId, OrderStatus.completed, emit);
  }

  Future<void> _updateStatus(
    String orderId,
    OrderStatus status,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        pendingOrderId: orderId,
        clearError: true,
      ),
    );

    final result = await _updateOrderStatus(orderId, status);
    result.fold(
      onSuccess: (updatedOrder) {
        final orders = state.orders
            .map((order) => order.id == orderId ? updatedOrder : order)
            .toList();
        emit(
          state.copyWith(
            orders: orders,
            pendingOrderId: null,
            clearPending: true,
            clearError: true,
          ),
        );
      },
      onFailure: (failure) {
        emit(
          state.copyWith(
            pendingOrderId: null,
            clearPending: true,
            errorMessage: failure.message,
          ),
        );
      },
    );
  }
}
