import '../../../../core/result/result.dart';
import '../entities/category.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  /// Returns the catalogue. Implementations may cache the result unless
  /// [forceRefresh] is true.
  Future<Result<List<Product>>> getProducts({bool forceRefresh = false});

  Future<Result<List<Product>>> getFeaturedProducts();

  Future<Result<List<Category>>> getCategories();

  Future<Result<Product>> getProductById(String id);
}
