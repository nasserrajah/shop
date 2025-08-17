import '../entities/product.dart';
import '../repositories/shop_repository.dart';

class GetProducts {
  final ShopRepository repository;
  GetProducts(this.repository);

  Future<List<Product>> call() async {
    return await repository.getProducts();
  }
}