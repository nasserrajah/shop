import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../../core/widgets/feedback.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/product_grid_sliver.dart';
import '../widgets/sort_sheet.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

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
        return Scaffold(
          appBar: AppBar(
            title: const Text('Products'),
            actions: [
              IconButton(
                tooltip: 'Sort products',
                onPressed: () async {
                  final selected = await showSortSheet(context, state.sort);
                  if (selected != null && context.mounted) {
                    context
                        .read<CatalogBloc>()
                        .add(CatalogSortChanged(selected));
                  }
                },
                icon: const Icon(Icons.tune_rounded),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CatalogState state) {
    if ((state.status == CatalogStatus.initial || state.isLoading) &&
        state.products.isEmpty) {
      return const AppLoading(message: 'Loading products...');
    }

    if (state.hasError && state.products.isEmpty) {
      return AppErrorView(
        message: state.errorMessage ?? 'Unable to load products.',
        onRetry: () => context
            .read<CatalogBloc>()
            .add(const LoadCatalogEvent(forceRefresh: true)),
      );
    }

    return Column(
      children: [
        if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: AppSearchBar(
                      value: state.query,
                      onChanged: (value) => context
                          .read<CatalogBloc>()
                          .add(CatalogSearchChanged(value)),
                    ),
                  ),
                ),
                if (state.categories.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isAll = index == 0;
                          final category =
                              isAll ? null : state.categories[index - 1];
                          final categoryName = category?.name.trim().toLowerCase();
                          final isSelected = isAll
                              ? state.selectedCategory == null
                              : categoryName == state.selectedCategory;
                          return ChoiceChip(
                            label: Text(
                              category?.displayName ?? 'All',
                            ),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (_) => context
                                .read<CatalogBloc>()
                                .add(CatalogCategorySelected(category?.name)),
                          );
                        },
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${state.visibleProducts.length} products',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (state.hasActiveFilters)
                          TextButton(
                            onPressed: () => context
                                .read<CatalogBloc>()
                                .add(const ClearCatalogFiltersEvent()),
                            child: const Text('Clear filters'),
                          ),
                        Text(
                          state.sort.label,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.visibleProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyView(
                      title: 'Nothing matches your filters',
                      message:
                          'Try another keyword or browse a different category.',
                      icon: Icons.filter_alt_off_rounded,
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
