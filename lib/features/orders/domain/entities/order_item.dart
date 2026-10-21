import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  const OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
    this.size,
  });

  final String productId;
  final String title;
  final String image;
  final double price;
  final int quantity;
  final String? size;

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [
        productId,
        title,
        image,
        price,
        quantity,
        size,
      ];
}
