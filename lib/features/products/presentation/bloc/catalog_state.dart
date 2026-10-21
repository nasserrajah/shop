import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_sort_option.dart';

enum CatalogStatus { initial, loading, loaded, failure }

class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.products = const [],
    this.visibleProducts = const [],
    this.featuredProducts = const [],
    this.categories = const [],
    this.query = '',
    this.selectedCategory,
    this.sort = ProductSortOption.featured,
    this.errorMessage,
  });

  final CatalogStatus status;
  final List<Product> products;
  final List<Product> visibleProducts;
  final List<Product> featuredProducts;
  final List<Category> categories;
  final String query;
  final String? selectedCategory;
  final ProductSortOption sort;
  final String? errorMessage;

  bool get isLoading => status == CatalogStatus.loading;

  bool get isLoaded => status == CatalogStatus.loaded;

  bool get hasError => status == CatalogStatus.failure;

  bool get hasActiveFilters =>
      query.trim().isNotEmpty || selectedCategory != null;

  int get activeFilterCount =>
      (query.trim().isNotEmpty ? 1 : 0) + (selectedCategory != null ? 1 : 0);

  bool get isEmpty => visibleProducts.isEmpty;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? products,
    List<Product>? visibleProducts,
    List<Product>? featuredProducts,
    List<Category>? categories,
    String? query,
    String? selectedCategory,
    bool clearCategory = false,
    ProductSortOption? sort,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      sort: sort ?? this.sort,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        visibleProducts,
        featuredProducts,
        categories,
        query,
        selectedCategory,
        sort,
        errorMessage,
      ];
}
