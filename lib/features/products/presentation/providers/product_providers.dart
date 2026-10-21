import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/filter_products.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_featured_products.dart';
import '../../domain/usecases/get_product_by_id.dart';
import '../../domain/usecases/get_products.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
  );
});

final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.watch(productRepositoryProvider));
});

final getFeaturedProductsProvider = Provider<GetFeaturedProducts>((ref) {
  return GetFeaturedProducts(ref.watch(productRepositoryProvider));
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(productRepositoryProvider));
});

final getProductByIdProvider = Provider<GetProductById>((ref) {
  return GetProductById(ref.watch(productRepositoryProvider));
});

final filterProductsProvider = Provider<FilterProducts>(
  (ref) => const FilterProducts(),
);

/// Catalogue state uses BLoC because it is a real event -> state workflow
/// (load, refresh, search, category selection, sorting, retry).
final catalogBlocProvider = Provider<CatalogBloc>((ref) {
  final bloc = CatalogBloc(
    getProducts: ref.watch(getProductsProvider),
    getFeaturedProducts: ref.watch(getFeaturedProductsProvider),
    getCategories: ref.watch(getCategoriesProvider),
    filterProducts: ref.watch(filterProductsProvider),
  );
  ref.onDispose(bloc.close);
  bloc.add(const LoadCatalogEvent());
  return bloc;
});

/// Product details can be loaded independently (deep links, favorites and
/// recently opened screens) and are therefore exposed as a Riverpod family.
final productDetailsProvider =
    FutureProvider.family<Product, String>((ref, productId) async {
  final result = await ref.watch(getProductByIdProvider)(productId);
  return result.fold(
    onSuccess: (product) => product,
    onFailure: (failure) => throw failure,
  );
});
