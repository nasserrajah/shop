import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/core/entities/payment_method.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/core/result/result.dart';
import 'package:shop/features/cart/domain/entities/cart.dart';
import 'package:shop/features/cart/domain/entities/cart_item.dart';
import 'package:shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop/features/orders/domain/entities/order.dart';
import 'package:shop/features/orders/domain/entities/order_item.dart';
import 'package:shop/features/orders/domain/entities/order_status.dart';
import 'package:shop/features/orders/domain/repositories/order_repository.dart';
import 'package:shop/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shop/features/products/data/models/category_model.dart';
import 'package:shop/features/products/data/models/product_model.dart';
import 'package:shop/features/products/domain/entities/category.dart';
import 'package:shop/features/products/domain/entities/product.dart';
import 'package:shop/features/products/domain/repositories/product_repository.dart';
import 'package:shop/features/profile/domain/entities/user_profile.dart';
import 'package:shop/features/profile/domain/repositories/profile_repository.dart';

/// Builds a product with sensible defaults so tests only override what they
/// care about.
Product buildProduct({
  String id = 'p1',
  String title = 'Running Shoes',
  double price = 49.99,
  String image = '',
  String category = 'shoes',
  String description = 'Comfortable running shoes for everyday training.',
  double rating = 4.5,
  int reviews = 12,
  List<String> sizes = const ['40', '41'],
  bool inStock = true,
}) {
  return Product(
    id: id,
    title: title,
    price: price,
    image: image,
    category: category,
    description: description,
    rating: rating,
    reviews: reviews,
    sizes: sizes,
    inStock: inStock,
  );
}

CartItem buildCartItem({
  Product? product,
  int quantity = 1,
  String? size,
}) {
  return CartItem(
    product: product ?? buildProduct(),
    quantity: quantity,
    size: size,
  );
}

Cart buildCart({List<CartItem> items = const []}) => Cart(items: items);

OrderItem buildOrderItem({
  String productId = 'p1',
  String title = 'Running Shoes',
  String image = '',
  double price = 49.99,
  int quantity = 1,
  String? size,
}) {
  return OrderItem(
    productId: productId,
    title: title,
    image: image,
    price: price,
    quantity: quantity,
    size: size,
  );
}

Order buildOrder({
  String id = 'ORD-1',
  List<OrderItem>? items,
  double subtotal = 49.99,
  double discount = 4,
  double delivery = 2,
  double total = 47.99,
  DateTime? createdAt,
  PaymentMethod paymentMethod = PaymentMethod.card,
  String address = '123 Main Street, New York',
  DateTime? deliveryTime,
  OrderStatus status = OrderStatus.active,
}) {
  return Order(
    id: id,
    items: items ?? [buildOrderItem()],
    subtotal: subtotal,
    discount: discount,
    delivery: delivery,
    total: total,
    createdAt: createdAt ?? DateTime(2026, 1, 1, 10),
    paymentMethod: paymentMethod,
    address: address,
    deliveryTime: deliveryTime,
    status: status,
  );
}

/// Creates an in-memory SharedPreferences instance for persistence tests.
Future<SharedPreferences> createTestPreferences([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// Product repository test double with configurable results per endpoint.
class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    List<Product> products = const [],
    List<Product>? featuredProducts,
    List<Category> categories = const [],
    this.failure,
    this.featuredFailure,
    this.categoriesFailure,
    this.productByIdFailure,
  })  : products = List<Product>.of(products),
        featuredProducts = List<Product>.of(featuredProducts ?? products),
        categories = List<Category>.of(categories);

  final List<Product> products;
  final List<Product> featuredProducts;
  final List<Category> categories;

  Failure? failure;
  Failure? featuredFailure;
  Failure? categoriesFailure;
  Failure? productByIdFailure;

  int productsCalls = 0;
  int featuredCalls = 0;
  int categoriesCalls = 0;
  bool lastForceRefresh = false;

  @override
  Future<Result<List<Product>>> getProducts({bool forceRefresh = false}) async {
    productsCalls++;
    lastForceRefresh = forceRefresh;
    if (failure != null) return Result.failure(failure!);
    return Result.success(List<Product>.of(products));
  }

  @override
  Future<Result<List<Product>>> getFeaturedProducts() async {
    featuredCalls++;
    if (featuredFailure != null) return Result.failure(featuredFailure!);
    return Result.success(List<Product>.of(featuredProducts));
  }

  @override
  Future<Result<List<Category>>> getCategories() async {
    categoriesCalls++;
    if (categoriesFailure != null) return Result.failure(categoriesFailure!);
    return Result.success(List<Category>.of(categories));
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    if (productByIdFailure != null) {
      return Result.failure(productByIdFailure!);
    }
    for (final product in products) {
      if (product.id == id) return Result.success(product);
    }
    return const Result.failure(
      NotFoundFailure('This product is no longer available.'),
    );
  }
}

/// Product remote data source test double used by repository tests.
class FakeProductRemoteDataSource implements ProductRemoteDataSource {
  FakeProductRemoteDataSource({
    List<ProductModel> products = const [],
    List<ProductModel>? featuredProducts,
    List<CategoryModel> categories = const [],
    this.productsError,
    this.featuredError,
    this.categoriesError,
  })  : products = List<ProductModel>.of(products),
        featuredProducts = List<ProductModel>.of(featuredProducts ?? products),
        categories = List<CategoryModel>.of(categories);

  final List<ProductModel> products;
  final List<ProductModel> featuredProducts;
  final List<CategoryModel> categories;
  final Object? productsError;
  final Object? featuredError;
  final Object? categoriesError;

  int productsCalls = 0;
  int featuredCalls = 0;
  int categoriesCalls = 0;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    productsCalls++;
    if (productsError != null) throw productsError!;
    return List<ProductModel>.of(products);
  }

  @override
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    featuredCalls++;
    if (featuredError != null) throw featuredError!;
    return List<ProductModel>.of(featuredProducts);
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    categoriesCalls++;
    if (categoriesError != null) throw categoriesError!;
    return List<CategoryModel>.of(categories);
  }
}

/// In-memory cart repository used by checkout and bloc tests.
class FakeCartRepository implements CartRepository {
  FakeCartRepository({
    this.cart = const Cart(),
    this.loadFailure,
    this.mutationFailure,
  });

  Cart cart;
  Failure? loadFailure;
  Failure? mutationFailure;
  int clearCalls = 0;
  int addCalls = 0;

  @override
  Future<Result<Cart>> getCart() async {
    if (loadFailure != null) return Result.failure(loadFailure!);
    return Result.success(cart);
  }

  @override
  Future<Result<Cart>> addItem(
    Product product, {
    String? size,
    int quantity = 1,
  }) async {
    addCalls++;
    if (mutationFailure != null) return Result.failure(mutationFailure!);
    final items = List<CartItem>.of(cart.items);
    final index = items.indexWhere((item) => item.product.id == product.id && item.size == size);
    if (index >= 0) {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + quantity,
      );
    } else {
      items.insert(
        0,
        CartItem(product: product, quantity: quantity, size: size),
      );
    }
    cart = Cart(items: items);
    return Result.success(cart);
  }

  @override
  Future<Result<Cart>> updateQuantity(String itemKey, int quantity) async {
    if (mutationFailure != null) return Result.failure(mutationFailure!);
    final items = List<CartItem>.of(cart.items);
    final index = items.indexWhere((item) => item.key == itemKey);
    if (index < 0) {
      return const Result.failure(
        ValidationFailure('This item is no longer in your cart.'),
      );
    }
    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }
    cart = Cart(items: items);
    return Result.success(cart);
  }

  @override
  Future<Result<Cart>> removeItem(String itemKey) async {
    if (mutationFailure != null) return Result.failure(mutationFailure!);
    cart = Cart(
      items: cart.items.where((item) => item.key != itemKey).toList(),
    );
    return Result.success(cart);
  }

  @override
  Future<Result<Cart>> clear() async {
    clearCalls++;
    if (mutationFailure != null) return Result.failure(mutationFailure!);
    cart = const Cart();
    return Result.success(cart);
  }
}

/// In-memory order repository used by checkout and bloc tests.
class FakeOrderRepository implements OrderRepository {
  FakeOrderRepository({
    List<Order> orders = const [],
    this.getFailure,
    this.placeFailure,
    this.updateFailure,
  }) : orders = List<Order>.of(orders);

  final List<Order> orders;
  Failure? getFailure;
  Failure? placeFailure;
  Failure? updateFailure;

  int getOrdersCalls = 0;
  int placeCalls = 0;
  int updateCalls = 0;
  Order? lastPlacedOrder;

  /// When set, [placeOrder] waits for this completer so tests can observe
  /// in-flight states deterministically.
  Completer<void>? placeGate;

  @override
  Future<Result<List<Order>>> getOrders() async {
    getOrdersCalls++;
    if (getFailure != null) return Result.failure(getFailure!);
    return Result.success(List<Order>.of(orders));
  }

  @override
  Future<Result<Order>> placeOrder(Order order) async {
    placeCalls++;
    if (placeFailure != null) return Result.failure(placeFailure!);
    if (placeGate != null) await placeGate!.future;
    lastPlacedOrder = order;
    orders.insert(0, order);
    return Result.success(order);
  }

  @override
  Future<Result<Order>> updateStatus(
    String orderId,
    OrderStatus status,
  ) async {
    updateCalls++;
    if (updateFailure != null) return Result.failure(updateFailure!);
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      return const Result.failure(
        NotFoundFailure('This order could not be found.'),
      );
    }
    final updated = orders[index].copyWith(status: status);
    orders[index] = updated;
    return Result.success(updated);
  }
}

/// Profile repository test double so widget tests never hit the network.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({UserProfile? profile})
      : profile = profile ?? UserProfile.guest();

  UserProfile profile;

  @override
  Future<Result<UserProfile>> getProfile() async => Result.success(profile);

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    this.profile = profile;
    return Result.success(profile);
  }

  @override
  Future<Result<UserProfile>> signOut() async {
    profile = UserProfile.guest();
    return Result.success(profile);
  }
}
