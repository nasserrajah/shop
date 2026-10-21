import 'package:equatable/equatable.dart';

import '../../../../core/utils/string_extensions.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.description = '',
    this.rating = 0,
    this.reviews = 0,
    this.sizes = const [],
    this.inStock = true,
  });

  final String id;
  final String title;
  final double price;
  final String image;
  final String category;
  final String description;
  final double rating;
  final int reviews;
  final List<String> sizes;
  final bool inStock;

  bool get hasSizes => sizes.isNotEmpty;

  String get displayCategory => category.titleCase;

  Product copyWith({
    String? id,
    String? title,
    double? price,
    String? image,
    String? category,
    String? description,
    double? rating,
    int? reviews,
    List<String>? sizes,
    bool? inStock,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      sizes: sizes ?? this.sizes,
      inStock: inStock ?? this.inStock,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        image,
        category,
        description,
        rating,
        reviews,
        sizes,
        inStock,
      ];
}
