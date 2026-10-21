import '../../../../core/result/result.dart';
import '../entities/category.dart';
import '../repositories/product_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final ProductRepository _repository;

  Future<Result<List<Category>>> call() => _repository.getCategories();
}
