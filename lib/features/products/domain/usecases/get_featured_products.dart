import '../../../../core/result/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetFeaturedProducts {
  const GetFeaturedProducts(this._repository);

  final ProductRepository _repository;

  Future<Result<List<Product>>> call() => _repository.getFeaturedProducts();
}
