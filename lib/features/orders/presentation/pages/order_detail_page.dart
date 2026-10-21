import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_status.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_status_timeline.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  Order? _findOrder(List<Order> orders) {
    for (final order in orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  Future<void> _cancel(BuildContext context, Order order) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel this order?',
      message:
          'Order #${formatShortOrderId(order.id)} will be cancelled. This cannot be undone.',
      confirmLabel: 'Cancel order',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    context.read<OrdersBloc>().add(CancelOrderEvent(order.id));
  }

  Future<void> _complete(BuildContext context, Order order) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Mark as delivered?',
      message: 'Confirm that you have received this order.',
      confirmLabel: 'Mark delivered',
    );
    if (!confirmed || !context.mounted) return;
    context.read<OrdersBloc>().add(CompleteOrderEvent(order.id));
    showAppSnackBar(context, 'Order marked as delivered');
  }

  Future<void> _reorder(BuildContext context, WidgetRef ref, Order order) async {
    for (final item in order.items) {
      final product = Product(
        id: item.productId,
        title: item.title,
        price: item.price,
        image: item.image,
        category: 'Reorder',
      );
      final result = await ref.read(cartControllerProvider.notifier).add(
            product,
            size: item.size,
            quantity: item.quantity,
          );
      if (result.isFailure) {
        if (context.mounted) {
          showAppSnackBar(
            context,
            result.failureOrNull!.message,
            isError: true,
          );
        }
        return;
      }
    }

    if (!context.mounted) return;
    showAppSnackBar(context, 'Items added back to your cart');
    await AppRouter.pushCart(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        final order = _findOrder(state.orders);

        if (order == null && state.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order details')),
            body: const AppLoading(message: 'Loading order...'),
          );
        }

        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order details')),
            body: AppEmptyView(
              title: 'Order not found',
              message: 'This order may have been removed from this device.',
              icon: Icons.receipt_long_outlined,
              actionLabel: 'Back to orders',
              onAction: () => Navigator.of(context).pop(),
            ),
          );
        }

        final isPending = state.pendingOrderId == order.id;

        return Scaffold(
          appBar: AppBar(
            title: Text('Order #${formatShortOrderId(order.id)}'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              _HeaderCard(order: order),
              const SizedBox(height: 14),
              _Card(
                title: 'Tracking',
                child: OrderStatusTimeline(status: order.status),
              ),
              const SizedBox(height: 14),
              _Card(
                title: 'Items',
                child: Column(
                  children: [
                    for (var index = 0; index < order.items.length; index++) ...[
                      _OrderItemRow(item: order.items[index]),
                      if (index != order.items.length - 1)
                        const Divider(height: 22),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                title: 'Delivery',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: order.address,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Payment',
                      value: order.paymentMethod.label,
                    ),
                    if (order.deliveryTime != null) ...[
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Delivery slot',
                        value: formatDateTime(order.deliveryTime!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                title: 'Payment summary',
                child: Column(
                  children: [
                    _SummaryLine(
                      label: 'Subtotal',
                      value: formatCurrency(order.subtotal),
                    ),
                    _SummaryLine(
                      label: 'Discount',
                      value: '-${formatCurrency(order.discount)}',
                    ),
                    _SummaryLine(
                      label: 'Delivery',
                      value: formatCurrency(order.delivery),
                    ),
                    const Divider(height: 20),
                    _SummaryLine(
                      label: 'Total',
                      value: formatCurrency(order.total),
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (order.status == OrderStatus.active) ...[
                FilledButton.icon(
                  onPressed: isPending ? null : () => _complete(context, order),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Mark as delivered'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isPending ? null : () => _cancel(context, order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel order'),
                ),
                const SizedBox(height: 8),
              ],
              TextButton.icon(
                onPressed: () => _reorder(context, ref, order),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Reorder these items'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = switch (order.status) {
      OrderStatus.active => AppColors.primary,
      OrderStatus.completed => AppColors.success,
      OrderStatus.cancelled => AppColors.danger,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.status.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(order.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                formatDateTime(order.createdAt),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white70,
                size: 15,
              ),
              const SizedBox(width: 6),
              Text(
                '${order.itemsCount} items',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ProductImageView(
          imageUrl: item.image,
          width: 62,
          height: 62,
          borderRadius: BorderRadius.circular(10),
          iconSize: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                [
                  'Qty ${item.quantity}',
                  if (item.size != null) 'Size ${item.size}',
                ].join(' • '),
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatCurrency(item.lineTotal),
          style: TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? null : scheme.onSurfaceVariant,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 16 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: bold ? scheme.primary : null,
              fontWeight: FontWeight.w700,
              fontSize: bold ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
