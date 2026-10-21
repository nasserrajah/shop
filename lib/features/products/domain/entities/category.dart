import 'package:equatable/equatable.dart';

import '../../../../core/utils/string_extensions.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.image,
    this.description = '',
  });

  final String id;
  final String name;
  final String image;
  final String description;

  String get displayName => name.titleCase;

  @override
  List<Object?> get props => [id, name, image, description];
}
