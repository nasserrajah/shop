import '../../../../core/result/result.dart';
import '../../../products/domain/entities/product.dart';

abstract class FavoriteRepository {
  Future<Result<List<Product>>> getFavorites();

  Future<Result<List<Product>>> toggleFavorite(Product product);

  Future<Result<bool>> isFavorite(String productId);

  Future<Result<void>> clearFavorites();
}
