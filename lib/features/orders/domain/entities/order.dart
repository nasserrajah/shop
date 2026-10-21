import 'package:equatable/equatable.dart';

import '../../../../core/entities/payment_method.dart';
import 'order_item.dart';
import 'order_status.dart';

class Order extends Equatable {
  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
    required this.createdAt,
    required this.paymentMethod,
    required this.address,
    this.deliveryTime,
    this.status = OrderStatus.active,
  });

  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;
  final DateTime createdAt;
  final PaymentMethod paymentMethod;
  final String address;
  final DateTime? deliveryTime;
  final OrderStatus status;

  int get itemsCount =>
      items.fold(0, (total, item) => total + item.quantity);

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? subtotal,
    double? discount,
    double? delivery,
    double? total,
    DateTime? createdAt,
    PaymentMethod? paymentMethod,
    String? address,
    DateTime? deliveryTime,
    OrderStatus? status,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      delivery: delivery ?? this.delivery,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        items,
        subtotal,
        discount,
        delivery,
        total,
        createdAt,
        paymentMethod,
        address,
        deliveryTime,
        status,
      ];
}
