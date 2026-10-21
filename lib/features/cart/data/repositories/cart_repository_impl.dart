import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final CartLocalDataSource _localDataSource;

  @override
  Future<Result<Cart>> getCart() async {
    try {
      final models = await _localDataSource.fetchItems();
      return Result.success(_toCart(models));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<Cart>> addItem(
    Product product, {
    String? size,
    int quantity = 1,
  }) async {
    if (quantity <= 0) {
      return const Result.failure(
        ValidationFailure('Quantity must be at least 1.'),
      );
    }
    if (!product.inStock) {
      return const Result.failure(
        ValidationFailure('This product is currently out of stock.'),
      );
    }

    final current = await _readItems();
    return current.fold(
      onFailure: (failure) => Result.failure(failure),
      onSuccess: (items) async {
        final key = _keyFor(product.id, size);
        final index = items.indexWhere((item) => _keyOf(item) == key);

        if (index >= 0) {
          final newQuantity = (items[index].quantity + quantity)
              .clamp(1, AppConstants.maxCartQuantity)
              .toInt();
          items[index] = CartItemModel(
            product: items[index].product,
            quantity: newQuantity,
            size: items[index].size,
          );
        } else {
          items.insert(
            0,
            CartItemModel(
              product: ProductModel.fromEntity(product),
              quantity:
                  quantity.clamp(1, AppConstants.maxCartQuantity).toInt(),
              size: size,
            ),
          );
        }

        return _persist(items);
      },
    );
  }

  @override
  Future<Result<Cart>> updateQuantity(String itemKey, int quantity) async {
    final current = await _readItems();
    return current.fold(
      onFailure: (failure) => Result.failure(failure),
      onSuccess: (items) async {
        final index = items.indexWhere((item) => _keyOf(item) == itemKey);
        if (index < 0) {
          return const Result.failure(
            ValidationFailure('This item is no longer in your cart.'),
          );
        }

        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = CartItemModel(
            product: items[index].product,
            quantity: quantity.clamp(1, AppConstants.maxCartQuantity).toInt(),
            size: items[index].size,
          );
        }

        return _persist(items);
      },
    );
  }

  @override
  Future<Result<Cart>> removeItem(String itemKey) async {
    final current = await _readItems();
    return current.fold(
      onFailure: (failure) => Result.failure(failure),
      onSuccess: (items) async {
        items.removeWhere((item) => _keyOf(item) == itemKey);
        return _persist(items);
      },
    );
  }

  @override
  Future<Result<Cart>> clear() async {
    try {
      await _localDataSource.saveItems(const []);
      return Result.success(const Cart());
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  Future<Result<List<CartItemModel>>> _readItems() async {
    try {
      final items = await _localDataSource.fetchItems();
      return Result.success(List<CartItemModel>.from(items));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  Future<Result<Cart>> _persist(List<CartItemModel> items) async {
    try {
      await _localDataSource.saveItems(items);
      return Result.success(_toCart(items));
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  Cart _toCart(List<CartItemModel> models) {
    return Cart(items: models.map((model) => model.toEntity()).toList());
  }

  String _keyFor(String productId, String? size) => '$productId::${size ?? ''}';

  String _keyOf(CartItemModel item) => _keyFor(item.product.id, item.size);
}
