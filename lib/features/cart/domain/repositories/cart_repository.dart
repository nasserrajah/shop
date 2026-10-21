import '../../../../core/result/result.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';

abstract class CartRepository {
  Future<Result<Cart>> getCart();

  Future<Result<Cart>> addItem(
    Product product, {
    String? size,
    int quantity = 1,
  });

  Future<Result<Cart>> updateQuantity(String itemKey, int quantity);

  Future<Result<Cart>> removeItem(String itemKey);

  Future<Result<Cart>> clear();
}
