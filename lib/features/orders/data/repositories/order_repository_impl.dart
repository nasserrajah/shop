import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required OrderLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final OrderLocalDataSource _localDataSource;

  @override
  Future<Result<List<Order>>> getOrders() async {
    try {
      final models = await _localDataSource.fetchOrders();
      final orders = models.map((model) => model.toEntity()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Result.success(orders);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<Order>> placeOrder(Order order) async {
    try {
      final models = List<OrderModel>.of(
        await _localDataSource.fetchOrders(),
      );
      models.insert(0, OrderModel.fromEntity(order));
      await _localDataSource.saveOrders(models);
      return Result.success(order);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Result<Order>> updateStatus(
    String orderId,
    OrderStatus status,
  ) async {
    try {
      final models = List<OrderModel>.of(
        await _localDataSource.fetchOrders(),
      );
      final index = models.indexWhere((order) => order.id == orderId);
      if (index < 0) {
        return const Result.failure(
          NotFoundFailure('This order could not be found.'),
        );
      }

      final updated = models[index].toEntity().copyWith(status: status);
      models[index] = OrderModel.fromEntity(updated);
      await _localDataSource.saveOrders(models);
      return Result.success(updated);
    } on Object catch (error) {
      return Result.failure(mapExceptionToFailure(error));
    }
  }
}
