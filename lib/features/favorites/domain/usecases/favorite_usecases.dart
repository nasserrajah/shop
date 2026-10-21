import '../../../../core/result/result.dart';
import '../../../products/domain/entities/product.dart';
import '../repositories/favorite_repository.dart';

class GetFavorites {
  const GetFavorites(this._repository);

  final FavoriteRepository _repository;

  Future<Result<List<Product>>> call() => _repository.getFavorites();
}

class ToggleFavorite {
  const ToggleFavorite(this._repository);

  final FavoriteRepository _repository;

  Future<Result<List<Product>>> call(Product product) {
    return _repository.toggleFavorite(product);
  }
}
