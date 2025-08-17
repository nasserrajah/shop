import '../repositories/shop_repository.dart';

class ToggleFavorite {
  final ShopRepository repository;
  ToggleFavorite(this.repository);

  Future<void> call(String productId) async {
    await repository.toggleFavorite(productId);
  }
}