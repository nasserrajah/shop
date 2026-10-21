import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_providers.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  Future<void> _increment(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(cartControllerProvider.notifier).increment(item.key);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) =>
          showAppSnackBar(context, failure.message, isError: true),
    );
  }

  Future<void> _decrement(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(cartControllerProvider.notifier).decrement(item.key);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) =>
          showAppSnackBar(context, failure.message, isError: true),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(cartControllerProvider.notifier).remove(item.key);
    if (!context.mounted) return;
    result.fold(
      onSuccess: (cart) {
        showAppSnackBar(
          context,
          '${item.product.title} removed from your cart',
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              ref.read(cartControllerProvider.notifier).add(
                    item.product,
                    size: item.size,
                    quantity: item.quantity,
                  );
            },
          ),
        );
      },
      onFailure: (failure) =>
          showAppSnackBar(context, failure.message, isError: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageView(
            imageUrl: item.product.image,
            width: 92,
            height: 100,
            borderRadius: BorderRadius.circular(14),
            iconSize: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.25,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove item',
                      onPressed: () => _remove(context, ref),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        size: 21,
                      ),
                    ),
                  ],
                ),
                Text(
                  item.size == null
                      ? item.product.displayCategory
                      : '${item.product.displayCategory} • Size ${item.size}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    QuantityStepper(
                      compact: true,
                      quantity: item.quantity,
                      onIncrease: () => _increment(context, ref),
                      onDecrease: () => _decrement(context, ref),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(item.lineTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                            fontSize: 15,
                          ),
                        ),
                        if (item.quantity > 1)
                          Text(
                            '${formatCurrency(item.product.price)} each',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
