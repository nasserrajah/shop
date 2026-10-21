import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

class OrdersState extends Equatable {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    this.pendingOrderId,
  });

  final List<Order> orders;
  final bool isLoading;
  final String? errorMessage;
  final String? pendingOrderId;

  bool get hasOrders => orders.isNotEmpty;

  bool get hasError => errorMessage != null;

  List<Order> byStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? errorMessage,
    String? pendingOrderId,
    bool clearError = false,
    bool clearPending = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      pendingOrderId: clearPending ? null : pendingOrderId ?? this.pendingOrderId,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        isLoading,
        errorMessage,
        pendingOrderId,
      ];
}
