import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.image,
    super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final rawImage = (json['image'] ?? '').toString();
    return CategoryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'General').toString(),
      image: rawImage.startsWith('/')
          ? '${ApiConstants.baseUrl}$rawImage'
          : rawImage,
      description: (json['description'] ?? '').toString(),
    );
  }
}
