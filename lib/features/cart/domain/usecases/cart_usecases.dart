import '../../../../core/result/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetCart {
  const GetCart(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call() => _repository.getCart();
}

class AddToCart {
  const AddToCart(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call(
    Product product, {
    String? size,
    int quantity = 1,
  }) {
    return _repository.addItem(product, size: size, quantity: quantity);
  }
}

class UpdateCartItemQuantity {
  const UpdateCartItemQuantity(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call(String itemKey, int quantity) {
    return _repository.updateQuantity(itemKey, quantity);
  }
}

class RemoveCartItem {
  const RemoveCartItem(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call(String itemKey) => _repository.removeItem(itemKey);
}

class ClearCart {
  const ClearCart(this._repository);

  final CartRepository _repository;

  Future<Result<Cart>> call() => _repository.clear();
}
