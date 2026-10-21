import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/product.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_carousel.dart';
import '../widgets/home_header.dart';
import '../widgets/product_card.dart';
import '../widgets/product_grid_sliver.dart';
import '../widgets/sort_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogBloc, CatalogState>(
      listenWhen: (previous, current) =>
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage &&
          current.products.isNotEmpty,
      listener: (context, state) {
        showAppSnackBar(context, state.errorMessage!, isError: true);
      },
      builder: (context, state) {
        if ((state.status == CatalogStatus.initial || state.isLoading) &&
            state.products.isEmpty) {
          return const SafeArea(child: AppLoading(message: 'Loading the store...'));
        }

        if (state.hasError && state.products.isEmpty) {
          return SafeArea(
            child: AppErrorView(
              message: state.errorMessage ?? 'Unable to load the store.',
              onRetry: () =>
                  context.read<CatalogBloc>().add(const LoadCatalogEvent()),
            ),
          );
        }

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<CatalogBloc>();
              bloc.add(const RefreshCatalogEvent());
              await bloc.stream.firstWhere(
                (next) => next.isLoaded || next.hasError,
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: HomeHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: AppSearchBar(
                      value: state.query,
                      onChanged: (value) => context
                          .read<CatalogBloc>()
                          .add(CatalogSearchChanged(value)),
                      onSubmitted: (value) => context
                          .read<CatalogBloc>()
                          .add(CatalogSearchChanged(value)),
                    ),
                  ),
                ),
                if (state.hasActiveFilters)
                  SliverToBoxAdapter(
                    child: _ActiveFilters(
                      state: state,
                      onClear: () => context
                          .read<CatalogBloc>()
                          .add(const ClearCatalogFiltersEvent()),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                const SliverToBoxAdapter(child: BannerSlider()),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Categories',
                    actionLabel: 'See All',
                    onAction: () => AppRouter.pushProducts(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CategoryCarousel(
                    categories: state.categories,
                    selectedCategory: state.selectedCategory,
                    onSelected: (category) => context
                        .read<CatalogBloc>()
                        .add(CatalogCategorySelected(category)),
                  ),
                ),
                if (!state.hasActiveFilters && state.featuredProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _FeaturedSection(
                      products: state.featuredProducts,
                      onSeeAll: () => AppRouter.pushProducts(context),
                      onProductTap: (product) =>
                          AppRouter.pushProductDetails(context, product.id),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.hasActiveFilters
                                ? 'Results (${state.visibleProducts.length})'
                                : 'Most Popular',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Sort products',
                          onPressed: () async {
                            final selected = await showSortSheet(
                              context,
                              state.sort,
                            );
                            if (selected != null && context.mounted) {
                              context
                                  .read<CatalogBloc>()
                                  .add(CatalogSortChanged(selected));
                            }
                          },
                          icon: const Icon(Icons.tune_rounded),
                        ),
                        TextButton(
                          onPressed: () => AppRouter.pushProducts(context),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.visibleProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyView(
                      title: 'No products found',
                      message:
                          'Try a different search term or clear the active filters.',
                      icon: Icons.search_off_rounded,
                      actionLabel: state.hasActiveFilters ? 'Clear filters' : null,
                      onAction: state.hasActiveFilters
                          ? () => context
                              .read<CatalogBloc>()
                              .add(const ClearCatalogFiltersEvent())
                          : null,
                    ),
                  )
                else
                  ProductGridSliver(
                    products: state.visibleProducts,
                    onTap: (product) =>
                        AppRouter.pushProductDetails(context, product.id),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.state, required this.onClear});

  final CatalogState state;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              state.selectedCategory == null
                  ? 'Search: "${state.query}"'
                  : 'Category: ${state.selectedCategory}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onClear,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({
    required this.products,
    required this.onSeeAll,
    required this.onProductTap,
  });

  final List<Product> products;
  final VoidCallback onSeeAll;
  final void Function(Product product) onProductTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Featured',
          actionLabel: 'See All',
          onAction: onSeeAll,
          padding: const EdgeInsets.fromLTRB(20, 18, 8, 0),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 264,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 188,
                child: ProductCard(
                  product: product,
                  onTap: () => onProductTap(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
