import 'package:flutter/material.dart';

import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../domain/entities/category.dart';

class CategoryCarousel extends StatelessWidget {
  const CategoryCarousel({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final selected = selectedCategory?.normalized;

    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAllSelected = selected == null;
            return _CategoryTile(
              label: 'All',
              image: null,
              selected: isAllSelected,
              onTap: () => onSelected(null),
            );
          }

          final category = categories[index - 1];
          final isSelected = selected == category.name.normalized;
          return _CategoryTile(
            label: category.displayName,
            image: category.image,
            selected: isSelected,
            onTap: () => onSelected(category.name),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 86,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.1)
                : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? scheme.primary : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: image == null
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: scheme.primary,
                        ),
                      )
                    : ProductImageView(
                        imageUrl: image!,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(12),
                      ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? scheme.primary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
