import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_message.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  String? _selectedSize;
  int _quantity = 1;

  Future<bool> _addToCart(Product product) async {
    final size = product.hasSizes
        ? (_selectedSize ?? product.sizes.first)
        : null;
    final result = await ref.read(cartControllerProvider.notifier).add(
          product,
          size: size,
          quantity: _quantity,
        );

    if (!mounted) return false;
    return result.fold<bool>(
      onSuccess: (_) {
        showAppSnackBar(context, 'Added ${product.title} to your cart');
        return true;
      },
      onFailure: (failure) {
        showAppSnackBar(context, failure.message, isError: true);
        return false;
      },
    );
  }

  Future<void> _buyNow(Product product) async {
    final added = await _addToCart(product);
    if (!mounted || !added) return;
    await AppRouter.pushCart(context);
  }

  Future<void> _toggleFavorite(Product product) async {
    final result =
        await ref.read(favoritesControllerProvider.notifier).toggle(product);
    if (!mounted) return;
    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) =>
          showAppSnackBar(context, failure.message, isError: true),
    );
  }

  Future<void> _share(Product product) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            'Check out ${product.title} at Eight Shop for ${formatCurrency(product.price)}!',
      ),
    );
    if (!mounted) return;
    showAppSnackBar(context, 'Product link copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));

    return productAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Product details')),
        body: const AppLoading(message: 'Loading product...'),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Product details')),
        body: AppErrorView(
          message: readableErrorMessage(
            error,
            fallback: 'Unable to load this product.',
          ),
          onRetry: () =>
              ref.invalidate(productDetailsProvider(widget.productId)),
        ),
      ),
      data: (product) {
        final isFavorite = ref.watch(isFavoriteProvider(product.id));
        final quantity = _quantity.clamp(1, 99).toInt();
        final total = product.price * quantity;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Product details'),
            actions: [
              IconButton(
                tooltip: 'Share product',
                onPressed: () => _share(product),
                icon: const Icon(Icons.ios_share_rounded),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: () => _toggleFavorite(product),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.danger : null,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImageView(
                  imageUrl: product.image,
                  width: double.infinity,
                  height: 330,
                  borderRadius: BorderRadius.circular(26),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${product.reviews} reviews)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    _StockBadge(inStock: product.inStock),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.displayCategory,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  formatCurrency(product.price),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Description',
                  child: Text(
                    product.description.trim().isEmpty
                        ? 'No description is available for this product yet.'
                        : product.description,
                    style: TextStyle(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (product.hasSizes) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Select size',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final size in product.sizes)
                          ChoiceChip(
                            label: Text(size),
                            selected: (_selectedSize ?? product.sizes.first) ==
                                size,
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _selectedSize = size),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Quantity',
                  child: Row(
                    children: [
                      QuantityStepper(
                        quantity: quantity,
                        onIncrease: () {
                          if (quantity < 99) {
                            setState(() => _quantity = quantity + 1);
                          }
                        },
                        onDecrease: () {
                          if (quantity > 1) {
                            setState(() => _quantity = quantity - 1);
                          }
                        },
                      ),
                      const Spacer(),
                      Text(
                        formatCurrency(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Delivery & returns',
                  child: Column(
                    children: const [
                      _InfoLine(
                        icon: Icons.local_shipping_outlined,
                        text: 'Fast delivery in 2 - 4 business days',
                      ),
                      SizedBox(height: 10),
                      _InfoLine(
                        icon: Icons.verified_outlined,
                        text: 'Free returns within 14 days',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(product),
        );
      },
    );
  }

  Widget _buildBottomBar(Product product) {
    final quantity = _quantity.clamp(1, 99).toInt();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formatCurrency(product.price * quantity),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: product.inStock ? () => _addToCart(product) : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text('Add to cart'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: product.inStock ? () => _buyNow(product) : null,
                  child: Text(product.inStock ? 'Buy now' : 'Sold out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final color = inStock ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        inStock ? 'In stock' : 'Out of stock',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
