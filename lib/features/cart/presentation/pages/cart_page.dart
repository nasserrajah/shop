import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/error_message.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../checkout/presentation/providers/checkout_providers.dart';
import '../../../shell/presentation/bloc/navigation_bloc.dart';
import '../../../shell/presentation/bloc/navigation_event.dart';
import '../../domain/entities/cart.dart';
import '../providers/cart_providers.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary_card.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartControllerProvider);

    return Scaffold(
      appBar: showBackButton ? AppBar(title: const Text('My cart')) : null,
      body: SafeArea(
        child: cartAsync.when(
          loading: () => const AppLoading(message: 'Loading your cart...'),
          error: (error, stackTrace) => AppErrorView(
            message: readableErrorMessage(
              error,
              fallback: 'Unable to load your cart.',
            ),
            onRetry: () => ref.read(cartControllerProvider.notifier).refresh(),
          ),
          data: (cart) => cart.isEmpty
              ? AppEmptyView(
                  title: 'Your cart is empty',
                  message:
                      'Add products you love and they will be waiting for you here.',
                  icon: Icons.shopping_bag_outlined,
                  actionLabel: 'Start shopping',
                  onAction: () => _startShopping(context),
                )
              : _CartContent(cart: cart, showHeader: !showBackButton),
        ),
      ),
    );
  }

  void _startShopping(BuildContext context) {
    if (showBackButton) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    context.read<NavigationBloc>().add(const NavigateTo(0));
  }
}

class _CartContent extends ConsumerWidget {
  const _CartContent({required this.cart, required this.showHeader});

  final Cart cart;
  final bool showHeader;

  Future<void> _clearCart(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear your cart?',
      message: 'All ${cart.itemCount} items will be removed from your cart.',
      confirmLabel: 'Clear cart',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final result = await ref.read(cartControllerProvider.notifier).clear();
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) => showAppSnackBar(context, 'Cart cleared'),
      onFailure: (failure) =>
          showAppSnackBar(context, failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(checkoutSummaryProvider);

    return Column(
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My cart',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${cart.itemCount} items',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Clear cart',
                  onPressed: () => _clearCart(context, ref),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
              ],
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: TextButton.icon(
                onPressed: () => _clearCart(context, ref),
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const Text('Clear cart'),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) =>
                CartItemTile(item: cart.items[index]),
          ),
        ),
        CartSummaryCard(
          summary: summary,
          onCheckout: () => AppRouter.pushCheckout(context),
        ),
      ],
    );
  }
}
