import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../data/datasources/order_local_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/order_usecases.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

final orderLocalDataSourceProvider = Provider<OrderLocalDataSource>((ref) {
  return OrderLocalDataSourceImpl(prefs: ref.watch(sharedPreferencesProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    localDataSource: ref.watch(orderLocalDataSourceProvider),
  );
});

final getOrdersProvider = Provider<GetOrders>((ref) {
  return GetOrders(ref.watch(orderRepositoryProvider));
});

final updateOrderStatusProvider = Provider<UpdateOrderStatus>((ref) {
  return UpdateOrderStatus(ref.watch(orderRepositoryProvider));
});

/// Orders use BLoC because they are an event-driven workflow with async
/// mutations. The bloc is app-scoped so the profile summary and the orders
/// page always observe the same data.
final ordersBlocProvider = Provider<OrdersBloc>((ref) {
  final bloc = OrdersBloc(
    getOrders: ref.watch(getOrdersProvider),
    updateOrderStatus: ref.watch(updateOrderStatusProvider),
  );
  ref.onDispose(bloc.close);
  bloc.add(const LoadOrdersEvent());
  return bloc;
});
