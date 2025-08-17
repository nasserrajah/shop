import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.image,
    required super.category,
    super.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'No title',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse('${json['price']}') ?? 0.0,
      image: json['image'] ?? (json['images'] is List && json['images'].isNotEmpty ? json['images'][0] : ''),
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
    );
  }
}