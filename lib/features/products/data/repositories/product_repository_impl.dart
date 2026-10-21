import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProductRemoteDataSource _remoteDataSource;

  List<Product>? _cachedProducts;

  @override
  Future<Result<List<Product>>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProducts != null) {
      return Result.success(List.unmodifiable(_cachedProducts!));
    }

    try {
      final models = await _remoteDataSource.fetchProducts();
      final products = models.cast<Product>().toList(growable: false);
      _cachedProducts = products;
      return Result.success(products);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<List<Product>>> getFeaturedProducts() async {
    try {
      final models = await _remoteDataSource.fetchFeaturedProducts();
      final products = models
          .cast<Product>()
          .take(AppConstants.featuredProductsLimit)
          .toList(growable: false);
      return Result.success(products);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final models = await _remoteDataSource.fetchCategories();
      return Result.success(models.cast<Category>().toList(growable: false));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    final cached = _cachedProducts;
    if (cached != null) {
      final product = _findById(cached, id);
      if (product != null) return Result.success(product);
    }

    final result = await getProducts(forceRefresh: true);
    return result.fold(
      onSuccess: (products) {
        final product = _findById(products, id);
        if (product == null) {
          return const Result<Product>.failure(
            NotFoundFailure('This product is no longer available.'),
          );
        }
        return Result.success(product);
      },
      onFailure: (failure) => Result<Product>.failure(failure),
    );
  }

  Product? _findById(List<Product> products, String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }
}
