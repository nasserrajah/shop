import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../shell/presentation/bloc/navigation_bloc.dart';
import '../../../shell/presentation/bloc/navigation_event.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_card.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  OrderStatus _selectedStatus = OrderStatus.active;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const LoadOrdersEvent());
  }

  Future<void> _cancelOrder(Order order) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel this order?',
      message:
          'Order #${order.id} will be cancelled. This action cannot be undone.',
      confirmLabel: 'Cancel order',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    context.read<OrdersBloc>().add(CancelOrderEvent(order.id));
  }

  void _browseProducts() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    context.read<NavigationBloc>().add(const NavigateTo(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
        actions: [
          IconButton(
            tooltip: 'Refresh orders',
            onPressed: () =>
                context.read<OrdersBloc>().add(const LoadOrdersEvent()),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listenWhen: (previous, current) =>
            current.errorMessage != previous.errorMessage ||
            (previous.pendingOrderId != null && current.pendingOrderId == null),
        listener: (context, state) {
          if (state.errorMessage != null) {
            showAppSnackBar(context, state.errorMessage!, isError: true);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.orders.isEmpty) {
            return const AppLoading(message: 'Loading your orders...');
          }
          if (state.hasError && state.orders.isEmpty) {
            return AppErrorView(
              message: state.errorMessage!,
              onRetry: () =>
                  context.read<OrdersBloc>().add(const LoadOrdersEvent()),
            );
          }

          final filtered = state.byStatus(_selectedStatus);

          return Column(
            children: [
              if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
              _StatusFilters(
                selected: _selectedStatus,
                orders: state.orders,
                onSelected: (status) =>
                    setState(() => _selectedStatus = status),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final bloc = context.read<OrdersBloc>();
                    bloc.add(const LoadOrdersEvent());
                    await bloc.stream.firstWhere(
                      (next) => !next.isLoading,
                    );
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 380,
                              child: AppEmptyView(
                                title: _emptyTitle(),
                                message: _emptyMessage(),
                                icon: _emptyIcon(),
                                actionLabel: _selectedStatus ==
                                        OrderStatus.active
                                    ? 'Browse products'
                                    : null,
                                onAction: _selectedStatus == OrderStatus.active
                                    ? _browseProducts
                                    : null,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final order = filtered[index];
                            return OrderCard(
                              order: order,
                              isPending: state.pendingOrderId == order.id,
                              onOpen: () =>
                                  AppRouter.pushOrderDetails(context, order.id),
                              onCancel: () => _cancelOrder(order),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _emptyTitle() {
    return switch (_selectedStatus) {
      OrderStatus.active => 'No active orders',
      OrderStatus.completed => 'No completed orders',
      OrderStatus.cancelled => 'No cancelled orders',
    };
  }

  String _emptyMessage() {
    return switch (_selectedStatus) {
      OrderStatus.active =>
        'Your next order will appear here so you can track it.',
      OrderStatus.completed =>
        'Completed orders will be listed here after delivery.',
      OrderStatus.cancelled =>
        'Orders you cancel will be kept here for your records.',
    };
  }

  IconData _emptyIcon() {
    return switch (_selectedStatus) {
      OrderStatus.active => Icons.receipt_long_outlined,
      OrderStatus.completed => Icons.check_circle_outline_rounded,
      OrderStatus.cancelled => Icons.cancel_outlined,
    };
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({
    required this.selected,
    required this.orders,
    required this.onSelected,
  });

  final OrderStatus selected;
  final List<Order> orders;
  final ValueChanged<OrderStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        itemCount: OrderStatus.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = OrderStatus.values[index];
          final count = orders.where((order) => order.status == status).length;
          return ChoiceChip(
            label: Text('${status.label} ($count)'),
            selected: selected == status,
            showCheckmark: false,
            onSelected: (_) => onSelected(status),
          );
        },
      ),
    );
  }
}
