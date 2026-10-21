import '../../../../core/utils/string_extensions.dart';
import '../entities/product.dart';
import '../entities/product_sort_option.dart';

/// Pure domain filtering/sorting logic for the catalogue.
class FilterProducts {
  const FilterProducts();

  List<Product> call({
    required List<Product> products,
    String query = '',
    String? category,
    ProductSortOption sort = ProductSortOption.featured,
  }) {
    final normalizedQuery = query.trim();
    final normalizedCategory = category?.trim().toLowerCase();

    final filtered = products.where((product) {
      final matchesQuery = normalizedQuery.isEmpty ||
          product.title.matchesQuery(normalizedQuery) ||
          product.category.matchesQuery(normalizedQuery) ||
          product.description.matchesQuery(normalizedQuery);

      final matchesCategory = normalizedCategory == null ||
          normalizedCategory.isEmpty ||
          product.category.normalized == normalizedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    switch (sort) {
      case ProductSortOption.featured:
        break;
      case ProductSortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.topRated:
        filtered.sort((a, b) {
          final rating = b.rating.compareTo(a.rating);
          return rating != 0 ? rating : b.reviews.compareTo(a.reviews);
        });
        break;
    }

    return filtered;
  }
}
