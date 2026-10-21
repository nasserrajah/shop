import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.image,
    required super.category,
    super.description,
    super.rating,
    super.reviews,
    super.sizes,
    super.inStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Untitled product').toString(),
      price: _toDouble(json['price']),
      image: _resolveImage(
        (json['image'] ??
                (json['images'] is List && (json['images'] as List).isNotEmpty
                    ? (json['images'] as List).first
                    : ''))
            .toString(),
      ),
      category: (json['category'] ?? 'general').toString(),
      description: (json['description'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      reviews: _toInt(json['reviews'] ?? json['reviewCount']),
      sizes: (json['sizes'] is List)
          ? (json['sizes'] as List)
              .map((size) => size.toString())
              .where((size) => size.isNotEmpty)
              .toList()
          : const [],
      inStock: json['inStock'] is bool ? json['inStock'] as bool : true,
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      price: product.price,
      image: product.image,
      category: product.category,
      description: product.description,
      rating: product.rating,
      reviews: product.reviews,
      sizes: product.sizes,
      inStock: product.inStock,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title,
      'price': price,
      'image': image,
      'category': category,
      'description': description,
      'rating': rating,
      'reviews': reviews,
      'sizes': sizes,
      'inStock': inStock,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }

  static String _resolveImage(String image) {
    if (image.isEmpty || image.startsWith('http')) return image;
    if (image.startsWith('/')) return '${ApiConstants.baseUrl}$image';
    return image;
  }
}
