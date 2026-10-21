import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersEvent extends OrdersEvent {
  const LoadOrdersEvent();
}

class CancelOrderEvent extends OrdersEvent {
  const CancelOrderEvent(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

class CompleteOrderEvent extends OrdersEvent {
  const CompleteOrderEvent(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
