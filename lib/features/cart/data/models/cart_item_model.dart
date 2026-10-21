import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel {
  const CartItemModel({
    required this.product,
    required this.quantity,
    this.size,
  });

  final ProductModel product;
  final int quantity;
  final String? size;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    return CartItemModel(
      product: ProductModel.fromJson(
        productJson is Map
            ? Map<String, dynamic>.from(productJson)
            : <String, dynamic>{},
      ),
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toInt()
          : int.tryParse('${json['quantity']}') ?? 1,
      size: json['size']?.toString(),
    );
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      product: ProductModel.fromEntity(item.product),
      quantity: item.quantity,
      size: item.size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
    };
  }

  CartItem toEntity() {
    return CartItem(
      product: product as Product,
      quantity: quantity,
      size: size,
    );
  }
}
