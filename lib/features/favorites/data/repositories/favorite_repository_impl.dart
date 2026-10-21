import '../../../../core/error/failure_mapper.dart';
import '../../../../core/result/result.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl({required FavoriteLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final FavoriteLocalDataSource _localDataSource;

  @override
  Future<Result<List<Product>>> getFavorites() async {
    try {
      final models = await _localDataSource.fetchFavorites();
      return Result.success(models.cast<Product>().toList(growable: false));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<List<Product>>> toggleFavorite(Product product) async {
    try {
      final models = List<ProductModel>.of(
        await _localDataSource.fetchFavorites(),
      );
      final index = models.indexWhere((item) => item.id == product.id);

      if (index >= 0) {
        models.removeAt(index);
      } else {
        models.insert(0, ProductModel.fromEntity(product));
      }

      await _localDataSource.saveFavorites(models);
      return Result.success(models.cast<Product>().toList(growable: false));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<bool>> isFavorite(String productId) async {
    try {
      final models = await _localDataSource.fetchFavorites();
      return Result.success(models.any((item) => item.id == productId));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<void>> clearFavorites() async {
    try {
      await _localDataSource.clear();
      return Result<void>.success(null);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }
}
