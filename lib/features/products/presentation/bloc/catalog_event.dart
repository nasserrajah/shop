import 'package:equatable/equatable.dart';

import '../../domain/entities/product_sort_option.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalogEvent extends CatalogEvent {
  const LoadCatalogEvent({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshCatalogEvent extends CatalogEvent {
  const RefreshCatalogEvent();
}

class CatalogSearchChanged extends CatalogEvent {
  const CatalogSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class CatalogCategorySelected extends CatalogEvent {
  const CatalogCategorySelected(this.category);

  /// Passing `null` clears the category filter.
  final String? category;

  @override
  List<Object?> get props => [category];
}

class CatalogSortChanged extends CatalogEvent {
  const CatalogSortChanged(this.sort);

  final ProductSortOption sort;

  @override
  List<Object?> get props => [sort];
}

class ClearCatalogFiltersEvent extends CatalogEvent {
  const ClearCatalogFiltersEvent();
}
