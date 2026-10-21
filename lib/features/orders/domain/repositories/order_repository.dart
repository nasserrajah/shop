import '../../../../core/result/result.dart';
import '../entities/order.dart';
import '../entities/order_status.dart';

abstract class OrderRepository {
  Future<Result<List<Order>>> getOrders();

  Future<Result<Order>> placeOrder(Order order);

  Future<Result<Order>> updateStatus(String orderId, OrderStatus status);
}
