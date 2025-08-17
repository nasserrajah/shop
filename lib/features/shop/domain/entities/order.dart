import 'package:equatable/equatable.dart';
import 'product.dart';

class Order extends Equatable {
  final String id;
  final List<Product> items;
  final double total;
  final String status;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    this.status = "Active",
  });

  Order copyWith({
    String? id,
    List<Product>? items,
    double? total,
    String? status,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, items, total, status];
}