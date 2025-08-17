import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String title;
  final double price;
  final String image;
  final String category;
  final String? description;
  final bool isFavorite;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
    this.description,
    this.isFavorite = false,
  });

  Product copyWith({
    String? id,
    String? title,
    double? price,
    String? image,
    String? category,
    String? description,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, price, image, category, description, isFavorite];
}