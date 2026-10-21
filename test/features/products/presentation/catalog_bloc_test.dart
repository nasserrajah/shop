import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/products/domain/entities/category.dart';
import 'package:shop/features/products/domain/entities/product_sort_option.dart';
import 'package:shop/features/products/domain/usecases/filter_products.dart';
import 'package:shop/features/products/domain/usecases/get_categories.dart';
import 'package:shop/features/products/domain/usecases/get_featured_products.dart';
import 'package:shop/features/products/domain/usecases/get_products.dart';
import 'package:shop/features/products/presentation/bloc/catalog_bloc.dart';
import 'package:shop/features/products/presentation/bloc/catalog_event.dart';
import 'package:shop/features/products/presentation/bloc/catalog_state.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  CatalogBloc buildBloc(FakeProductRepository repository) {
    return CatalogBloc(
      getProducts: GetProducts(repository),
      getFeaturedProducts: GetFeaturedProducts(repository),
      getCategories: GetCategories(repository),
      filterProducts: const FilterProducts(),
    );
  }

  final shoes = buildProduct(
    id: '1',
    title: 'Running Shoes',
    price: 80,
    category: 'shoes',
    rating: 4.2,
    reviews: 10,
  );
  final jacket = buildProduct(
    id: '2',
    title: 'Winter Jacket',
    price: 120,
    category: 'winter',
    rating: 4.8,
    reviews: 4,
  );
  final sandals = buildProduct(
    id: '3',
    title: 'Summer Sandals',
    price: 30,
    category: 'summer',
    rating: 4.8,
    reviews: 90,
  );
  final products = [shoes, jacket, sandals];
  const categories = [
    Category(id: 'shoes', name: 'Shoes', image: ''),
    Category(id: 'winter', name: 'Winter', image: ''),
    Category(id: 'summer', name: 'Summer', image: ''),
  ];

  group('CatalogBloc', () {
    test('loads products, featured products and categories', () async {
      final repository = FakeProductRepository(
        products: products,
        categories: categories,
      );
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final states = <CatalogState>[];
      final subscription = bloc.stream.listen(states.add);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.loaded,
      );
      bloc.add(const LoadCatalogEvent());
      final state = await loaded;

      expect(states.first.status, CatalogStatus.loading);
      expect(state.products, products);
      expect(state.visibleProducts, products);
      expect(state.featuredProducts, products);
      expect(state.categories, categories);
      expect(state.errorMessage, isNull);
      expect(repository.productsCalls, 1);
      expect(repository.featuredCalls, 1);
      expect(repository.categoriesCalls, 1);

      await subscription.cancel();
    });

    test('reports a failure when the catalogue cannot load', () async {
      final repository = FakeProductRepository(
        failure: const NetworkFailure('No internet'),
      );
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final failed = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.failure,
      );
      bloc.add(const LoadCatalogEvent());
      final state = await failed;

      expect(state.hasError, isTrue);
      expect(state.errorMessage, 'No internet');
      expect(state.products, isEmpty);
      expect(state.visibleProducts, isEmpty);
    });

    test('keeps cached products visible when a refresh fails', () async {
      final repository = FakeProductRepository(products: products);
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.loaded,
      );
      bloc.add(const LoadCatalogEvent());
      await loaded;

      repository.failure = const ServerFailure('Refresh failed');
      final refreshed = bloc.stream.firstWhere(
        (state) => state.errorMessage == 'Refresh failed',
      );
      bloc.add(const RefreshCatalogEvent());
      final state = await refreshed;

      expect(state.status, CatalogStatus.loaded);
      expect(state.products, products);
      expect(state.visibleProducts, products);
      expect(repository.lastForceRefresh, isTrue);
    });

    test('searches across the catalogue and clears filters', () async {
      final bloc = buildBloc(
        FakeProductRepository(products: products, categories: categories),
      );
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.loaded,
      );
      bloc.add(const LoadCatalogEvent());
      await loaded;

      final searched = bloc.stream.firstWhere(
        (state) => state.query == 'jacket',
      );
      bloc.add(const CatalogSearchChanged('jacket'));
      final searchState = await searched;

      expect(searchState.visibleProducts, [jacket]);
      expect(searchState.hasActiveFilters, isTrue);
      expect(searchState.activeFilterCount, 1);

      final cleared = bloc.stream.firstWhere(
        (state) => state.query.isEmpty && !state.hasActiveFilters,
      );
      bloc.add(const ClearCatalogFiltersEvent());
      final clearState = await cleared;

      expect(clearState.visibleProducts, products);
      expect(clearState.selectedCategory, isNull);
    });

    test('toggles a category filter and normalizes its name', () async {
      final bloc = buildBloc(
        FakeProductRepository(products: products, categories: categories),
      );
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.loaded,
      );
      bloc.add(const LoadCatalogEvent());
      await loaded;

      final selected = bloc.stream.firstWhere(
        (state) => state.selectedCategory == 'shoes',
      );
      bloc.add(const CatalogCategorySelected('Shoes'));
      final selectedState = await selected;

      expect(selectedState.visibleProducts, [shoes]);
      expect(selectedState.activeFilterCount, 1);

      final deselected = bloc.stream.firstWhere(
        (state) =>
            state.selectedCategory == null &&
            state.visibleProducts.length == products.length,
      );
      bloc.add(const CatalogCategorySelected('shoes'));
      final deselectedState = await deselected;

      expect(deselectedState.selectedCategory, isNull);
      expect(deselectedState.visibleProducts, products);
    });

    test('sorts visible products', () async {
      final bloc = buildBloc(FakeProductRepository(products: products));
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.loaded,
      );
      bloc.add(const LoadCatalogEvent());
      await loaded;

      final sorted = bloc.stream.firstWhere(
        (state) => state.sort == ProductSortOption.priceLowToHigh,
      );
      bloc.add(const CatalogSortChanged(ProductSortOption.priceLowToHigh));
      final state = await sorted;

      expect(state.visibleProducts.map((product) => product.id), ['3', '1', '2']);
    });

    test('falls back to products when featured and categories fail', () async {
      final repository = FakeProductRepository(
        products: products,
        featuredFailure: const ServerFailure('Featured unavailable'),
        categoriesFailure: const ServerFailure('Categories unavailable'),
      );
      final bloc = buildBloc(repository);
      addTearDown(bloc.close);

      final loaded = bloc.stream.firstWhere(
        (state) => state.status == CatalogStatus.loaded,
      );
      bloc.add(const LoadCatalogEvent());
      final state = await loaded;

      expect(state.featuredProducts, products);
      expect(
        state.categories.map((category) => category.name),
        ['Shoes', 'Summer', 'Winter'],
      );
      expect(state.categories.map((category) => category.image), [
        shoes.image,
        sandals.image,
        jacket.image,
      ]);
    });
  });
}
