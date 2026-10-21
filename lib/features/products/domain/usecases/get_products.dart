import '../../../../core/result/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  Future<Result<List<Product>>> call({bool forceRefresh = false}) {
    return _repository.getProducts(forceRefresh: forceRefresh);
  }
}
