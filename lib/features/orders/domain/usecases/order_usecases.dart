import '../../../../core/result/result.dart';
import '../entities/order.dart';
import '../entities/order_status.dart';
import '../repositories/order_repository.dart';

class GetOrders {
  const GetOrders(this._repository);

  final OrderRepository _repository;

  Future<Result<List<Order>>> call() => _repository.getOrders();
}

class UpdateOrderStatus {
  const UpdateOrderStatus(this._repository);

  final OrderRepository _repository;

  Future<Result<Order>> call(String orderId, OrderStatus status) {
    return _repository.updateStatus(orderId, status);
  }
}
