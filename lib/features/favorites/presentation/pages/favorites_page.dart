import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/error_message.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../shell/presentation/bloc/navigation_bloc.dart';
import '../../../shell/presentation/bloc/navigation_event.dart';
import '../providers/favorites_providers.dart';

final favoritesQueryProvider = StateProvider<String>((ref) => '');

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesControllerProvider);
    final query = ref.watch(favoritesQueryProvider);

    return Scaffold(
      appBar: showBackButton
          ? AppBar(title: const Text('Favorites'))
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favorites',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${favoritesAsync.valueOrNull?.length ?? 0} saved items',
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
                    tooltip: 'Refresh favorites',
                    onPressed: () =>
                        ref.read(favoritesControllerProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            if (favoritesAsync.hasValue && favoritesAsync.value!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: AppSearchBar(
                  value: query,
                  hintText: 'Search your favorites',
                  onChanged: (value) =>
                      ref.read(favoritesQueryProvider.notifier).state = value,
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: favoritesAsync.when(
                loading: () => const AppLoading(),
                error: (error, stackTrace) => AppErrorView(
                  message: readableErrorMessage(
                    error,
                    fallback: 'Unable to load your favorites.',
                  ),
                  onRetry: () => ref.invalidate(favoritesControllerProvider),
                ),
                data: (favorites) {
                  if (favorites.isEmpty) {
                    return AppEmptyView(
                      title: 'No favorites yet',
                      message:
                          'Tap the heart on a product to keep it close at hand.',
                      icon: Icons.favorite_border_rounded,
                      actionLabel: 'Browse products',
                      onAction: () => context
                          .read<NavigationBloc>()
                          .add(const NavigateTo(0)),
                    );
                  }

                  final filtered = _filter(favorites, query);
                  if (filtered.isEmpty) {
                    return AppEmptyView(
                      title: 'No matching favorites',
                      message: 'Try a different search term.',
                      icon: Icons.search_off_rounded,
                      actionLabel: 'Clear search',
                      onAction: () =>
                          ref.read(favoritesQueryProvider.notifier).state = '',
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return ProductCard(
                        product: product,
                        onTap: () => AppRouter.pushProductDetails(
                          context,
                          product.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _filter(List<Product> favorites, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return favorites;
    return favorites
        .where(
          (product) =>
              product.title.toLowerCase().contains(normalized) ||
              product.category.toLowerCase().contains(normalized),
        )
        .toList();
  }
}
