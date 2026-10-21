import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/filter_products.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_featured_products.dart';
import '../../domain/usecases/get_products.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({
    required GetProducts getProducts,
    required GetFeaturedProducts getFeaturedProducts,
    required GetCategories getCategories,
    required FilterProducts filterProducts,
  })  : _getProducts = getProducts,
        _getFeaturedProducts = getFeaturedProducts,
        _getCategories = getCategories,
        _filterProducts = filterProducts,
        super(const CatalogState()) {
    on<LoadCatalogEvent>(_onLoad);
    on<RefreshCatalogEvent>(_onRefresh);
    on<CatalogSearchChanged>(_onSearchChanged);
    on<CatalogCategorySelected>(_onCategorySelected);
    on<CatalogSortChanged>(_onSortChanged);
    on<ClearCatalogFiltersEvent>(_onClearFilters);
  }

  final GetProducts _getProducts;
  final GetFeaturedProducts _getFeaturedProducts;
  final GetCategories _getCategories;
  final FilterProducts _filterProducts;

  Future<void> _onLoad(
    LoadCatalogEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        clearError: true,
      ),
    );

    final productsFuture = _getProducts(forceRefresh: event.forceRefresh);
    final featuredFuture = _getFeaturedProducts();
    final categoriesFuture = _getCategories();

    final productsResult = await productsFuture;
    final featuredResult = await featuredFuture;
    final categoriesResult = await categoriesFuture;

    final products = productsResult.dataOrNull;
    if (products == null) {
      final message = productsResult.failureOrNull?.message ??
          'Unable to load products right now.';
      if (state.products.isNotEmpty) {
        emit(
          state.copyWith(
            status: CatalogStatus.loaded,
            errorMessage: message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CatalogStatus.failure,
            errorMessage: message,
          ),
        );
      }
      return;
    }

    final featured = featuredResult.dataOrNull ?? products.take(8).toList();
    final categories = categoriesResult.dataOrNull ?? _deriveCategories(products);

    emit(
      _applyFilters(
        state.copyWith(
          status: CatalogStatus.loaded,
          products: products,
          featuredProducts: featured,
          categories: categories,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onRefresh(
    RefreshCatalogEvent event,
    Emitter<CatalogState> emit,
  ) {
    return _onLoad(const LoadCatalogEvent(forceRefresh: true), emit);
  }

  void _onSearchChanged(
    CatalogSearchChanged event,
    Emitter<CatalogState> emit,
  ) {
    emit(_applyFilters(state.copyWith(query: event.query)));
  }

  void _onCategorySelected(
    CatalogCategorySelected event,
    Emitter<CatalogState> emit,
  ) {
    final normalized = event.category?.normalized;
    final current = state.selectedCategory?.normalized;
    final next = normalized == current ? null : normalized;
    emit(
      _applyFilters(
        state.copyWith(
          selectedCategory: next,
          clearCategory: next == null,
        ),
      ),
    );
  }

  void _onSortChanged(
    CatalogSortChanged event,
    Emitter<CatalogState> emit,
  ) {
    emit(_applyFilters(state.copyWith(sort: event.sort)));
  }

  void _onClearFilters(
    ClearCatalogFiltersEvent event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      _applyFilters(
        state.copyWith(
          query: '',
          selectedCategory: null,
          clearCategory: true,
        ),
      ),
    );
  }

  CatalogState _applyFilters(CatalogState state) {
    final visible = _filterProducts(
      products: state.products,
      query: state.query,
      category: state.selectedCategory,
      sort: state.sort,
    );
    return state.copyWith(visibleProducts: visible);
  }

  List<Category> _deriveCategories(List<Product> products) {
    final map = <String, Category>{};
    for (final product in products) {
      final key = product.category.normalized;
      if (key.isEmpty) continue;
      map.putIfAbsent(
        key,
        () => Category(
          id: key,
          name: product.category.titleCase,
          image: product.image,
        ),
      );
    }
    return map.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}
