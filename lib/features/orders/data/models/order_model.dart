import '../../../../core/entities/payment_method.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import 'order_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
    required this.createdAt,
    required this.paymentMethod,
    required this.address,
    required this.status,
    this.deliveryTime,
  });

  final String id;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;
  final DateTime createdAt;
  final PaymentMethod paymentMethod;
  final String address;
  final DateTime? deliveryTime;
  final OrderStatus status;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      items: json['items'] is List
          ? (json['items'] as List)
              .whereType<Map>()
              .map((item) => OrderItemModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ))
              .toList()
          : const [],
      subtotal: _toDouble(json['subtotal']),
      discount: _toDouble(json['discount']),
      delivery: _toDouble(json['delivery']),
      total: _toDouble(json['total']),
      createdAt: DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      paymentMethod: PaymentMethod.fromName(
        (json['paymentMethod'] ?? 'cash').toString(),
      ),
      address: (json['address'] ?? '').toString(),
      deliveryTime: json['deliveryTime'] == null
          ? null
          : DateTime.tryParse('${json['deliveryTime']}'),
      status: OrderStatus.fromName((json['status'] ?? 'active').toString()),
    );
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      items: order.items.map(OrderItemModel.fromEntity).toList(),
      subtotal: order.subtotal,
      discount: order.discount,
      delivery: order.delivery,
      total: order.total,
      createdAt: order.createdAt,
      paymentMethod: order.paymentMethod,
      address: order.address,
      deliveryTime: order.deliveryTime,
      status: order.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'delivery': delivery,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'address': address,
      'deliveryTime': deliveryTime?.toIso8601String(),
      'status': status.name,
    };
  }

  Order toEntity() {
    return Order(
      id: id,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      total: total,
      createdAt: createdAt,
      paymentMethod: paymentMethod,
      address: address,
      deliveryTime: deliveryTime,
      status: status,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }
}
