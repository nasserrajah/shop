import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_data_source.dart';


class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;
  final List<Product> _favoriteProducts = [];
  final List<Order> _orders = [];

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Product>> getProducts() async {
    final products = await remoteDataSource.fetchProducts();
    return products.map((product) {
      final isFavorite = _favoriteProducts.any((p) => p.id == product.id);
      return product.copyWith(isFavorite: isFavorite);
    }).toList();
  }

  @override
  Future<List<Product>> getFavoriteProducts() async {
    return List.from(_favoriteProducts); // Return a copy to prevent external modification
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    final products = await remoteDataSource.fetchProducts();
    final product = products.firstWhere((p) => p.id == productId);

    final existingIndex = _favoriteProducts.indexWhere((p) => p.id == productId);

    if (existingIndex >= 0) {
      _favoriteProducts.removeAt(existingIndex);
    } else {
      _favoriteProducts.add(product.copyWith(isFavorite: true));
    }
  }

  @override
  Future<void> saveOrder(Order order) async {
    _orders.add(order);
    print('تم حفظ الطلب: ${order.id}'); // للتتبع
  }

  @override
  Future<List<Order>> getOrders() async {
    return List.from(_orders); // إرجاع نسخة من القائمة
  }
}