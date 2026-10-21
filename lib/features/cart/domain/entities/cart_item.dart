import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    this.size,
  });

  final Product product;
  final int quantity;
  final String? size;

  String get key => '${product.id}::${size ?? ''}';

  double get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity, String? size}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [product, quantity, size];
}
