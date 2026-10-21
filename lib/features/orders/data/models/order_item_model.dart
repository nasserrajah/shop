import '../../domain/entities/order_item.dart';

class OrderItemModel {
  const OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: (json['productId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price']}') ?? 0,
      quantity: json['quantity'] is num
          ? (json['quantity'] as num).toInt()
          : int.tryParse('${json['quantity']}') ?? 1,
      size: json['size']?.toString(),
    );
  }

  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      productId: item.productId,
      title: item.title,
      image: item.image,
      price: item.price,
      quantity: item.quantity,
      size: item.size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'image': image,
      'price': price,
      'quantity': quantity,
      'size': size,
    };
  }

  OrderItem toEntity() {
    return OrderItem(
      productId: productId,
      title: title,
      image: image,
      price: price,
      quantity: quantity,
      size: size,
    );
  }
}
