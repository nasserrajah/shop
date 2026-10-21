import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop/app.dart';
import 'package:shop/core/di/core_providers.dart';
import 'package:shop/features/products/domain/entities/category.dart';
import 'package:shop/features/products/presentation/providers/product_providers.dart';
import 'package:shop/features/profile/presentation/providers/profile_providers.dart';
import 'package:shop/features/shell/presentation/app_shell.dart';

import 'helpers/test_fixtures.dart';

void main() {
  testWidgets('the app boots, renders the store and switches tabs', (
    tester,
  ) async {
    final prefs = await createTestPreferences();
    final products = [
      buildProduct(id: '1', title: 'Running Shoes', price: 49.99),
      buildProduct(id: '2', title: 'Winter Jacket', price: 99, category: 'winter'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(
              products: products,
              categories: const [
                Category(id: 'shoes', name: 'Shoes', image: ''),
                Category(id: 'winter', name: 'Winter', image: ''),
              ],
            ),
          ),
          profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
        ],
        child: const ShopApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Guest Shopper'), findsOneWidget);
    expect(find.text('Get Winter Discount'), findsOneWidget);

    Finder navIcon(IconData icon) => find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.byIcon(icon),
        );

    expect(navIcon(Icons.home_rounded), findsOneWidget);
    expect(navIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(navIcon(Icons.shopping_bag_outlined), findsOneWidget);
    expect(navIcon(Icons.person_outline_rounded), findsOneWidget);

    await tester.tap(navIcon(Icons.shopping_bag_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(navIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();
    expect(find.text('No favorites yet'), findsOneWidget);

    await tester.tap(navIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Guest Shopper'), findsWidgets);

    // Unmount so the rotating banner timer is disposed before the test ends.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
