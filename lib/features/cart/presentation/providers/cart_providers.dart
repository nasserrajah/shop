import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../data/datasources/cart_local_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/cart_usecases.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSourceImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
  );
});

final getCartProvider = Provider<GetCart>((ref) {
  return GetCart(ref.watch(cartRepositoryProvider));
});

final addToCartProvider = Provider<AddToCart>((ref) {
  return AddToCart(ref.watch(cartRepositoryProvider));
});

final updateCartItemQuantityProvider =
    Provider<UpdateCartItemQuantity>((ref) {
  return UpdateCartItemQuantity(ref.watch(cartRepositoryProvider));
});

final removeCartItemProvider = Provider<RemoveCartItem>((ref) {
  return RemoveCartItem(ref.watch(cartRepositoryProvider));
});

final clearCartProvider = Provider<ClearCart>((ref) {
  return ClearCart(ref.watch(cartRepositoryProvider));
});

/// Cart state is mutation-heavy but fully local. Riverpod keeps it reactive
/// for the shell badge, cart page and checkout summary at the same time.
class CartController extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() async {
    final result = await ref.watch(getCartProvider)();
    return result.fold(
      onSuccess: (cart) => cart,
      onFailure: (failure) => throw failure,
    );
  }

  Future<Result<Cart>> add(
    Product product, {
    String? size,
    int quantity = 1,
  }) {
    return _run(
      () => ref.read(addToCartProvider)(
        product,
        size: size,
        quantity: quantity,
      ),
    );
  }

  Future<Result<Cart>> increment(String itemKey) {
    final cart = state.valueOrNull;
    if (cart == null) {
      return Future.value(
        Result.failure(
          const CacheFailure('Your cart is still loading. Please try again.'),
        ),
      );
    }
    final current = cart.quantityFor(itemKey);
    return updateQuantity(itemKey, current + 1);
  }

  Future<Result<Cart>> decrement(String itemKey) {
    final cart = state.valueOrNull;
    if (cart == null) {
      return Future.value(
        Result.failure(
          const CacheFailure('Your cart is still loading. Please try again.'),
        ),
      );
    }
    final current = cart.quantityFor(itemKey);
    return updateQuantity(itemKey, current - 1);
  }

  Future<Result<Cart>> updateQuantity(String itemKey, int quantity) {
    return _run(
      () => ref.read(updateCartItemQuantityProvider)(itemKey, quantity),
    );
  }

  Future<Result<Cart>> remove(String itemKey) {
    return _run(() => ref.read(removeCartItemProvider)(itemKey));
  }

  Future<Result<Cart>> clear() {
    return _run(() => ref.read(clearCartProvider)());
  }

  Future<void> refresh() async {
    final result = await ref.read(getCartProvider)();
    result.fold(
      onSuccess: (cart) => state = AsyncData(cart),
      onFailure: (failure) => state = AsyncError(failure, StackTrace.current),
    );
  }

  Future<Result<Cart>> _run(Future<Result<Cart>> Function() operation) async {
    final result = await operation();
    result.fold(
      onSuccess: (cart) => state = AsyncData(cart),
      onFailure: (_) {},
    );
    return result;
  }
}

final cartControllerProvider =
    AsyncNotifierProvider<CartController, Cart>(CartController.new);

final cartProvider = cartControllerProvider;

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartControllerProvider).valueOrNull?.itemCount ?? 0;
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartControllerProvider).valueOrNull?.subtotal ?? 0;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartControllerProvider).valueOrNull;
  return cart == null || cart.isEmpty;
});
