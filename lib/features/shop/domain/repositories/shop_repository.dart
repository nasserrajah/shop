import '../entities/product.dart';
import '../entities/order.dart';

abstract class ShopRepository {
  Future<List<Product>> getProducts();
  Future<List<Product>> getFavoriteProducts();
  Future<void> toggleFavorite(String productId);

  Future<void> saveOrder(Order order);
  Future<List<Order>> getOrders();
}