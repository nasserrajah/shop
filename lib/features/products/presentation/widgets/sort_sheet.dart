import 'package:flutter/material.dart';

import '../../domain/entities/product_sort_option.dart';

Future<ProductSortOption?> showSortSheet(
  BuildContext context,
  ProductSortOption selected,
) {
  return showModalBottomSheet<ProductSortOption>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Sort products',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            for (final option in ProductSortOption.values)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(option.label),
                trailing: option == selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Theme.of(sheetContext).colorScheme.primary,
                      )
                    : const Icon(Icons.circle_outlined, size: 20),
                onTap: () => Navigator.of(sheetContext).pop(option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
