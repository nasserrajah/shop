import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/core/constants/app_constants.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:shop/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shop/features/cart/domain/entities/cart.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CartRepositoryImpl repository;
  late SharedPreferences prefs;

  CartRepositoryImpl buildRepository() {
    return CartRepositoryImpl(
      localDataSource: CartLocalDataSourceImpl(
        prefs: prefs,
      ),
    );
  }

  group('CartRepositoryImpl', () {
    setUp(() async {
      prefs = await createTestPreferences();
      repository = buildRepository();
    });

    test('starts with an empty cart', () async {
      final result = await repository.getCart();

      expect(result.dataOrNull, const Cart());
      expect(result.dataOrNull!.isEmpty, isTrue);
    });

    test('adds an item and persists it across repository instances', () async {
      final product = buildProduct(price: 20, sizes: const ['M', 'L']);

      final added = await repository.addItem(
        product,
        size: 'M',
        quantity: 2,
      );

      final cart = added.dataOrNull!;
      expect(cart.items, hasLength(1));
      expect(cart.items.single.product.id, 'p1');
      expect(cart.items.single.quantity, 2);
      expect(cart.items.single.size, 'M');
      expect(cart.subtotal, 40);
      expect(cart.itemCount, 2);

      final reloaded = await buildRepository().getCart();
      expect(reloaded.dataOrNull, cart);
    });

    test('rejects out-of-stock products', () async {
      final result = await repository.addItem(buildProduct(inStock: false));

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('out of stock'));
      expect((await repository.getCart()).dataOrNull!.isEmpty, isTrue);
    });

    test('rejects non-positive quantities', () async {
      final result = await repository.addItem(buildProduct(), quantity: 0);

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('at least 1'));
    });

    test('merges matching product and size lines up to the limit', () async {
      await repository.addItem(buildProduct(), size: 'M', quantity: 60);
      final result = await repository.addItem(
        buildProduct(),
        size: 'M',
        quantity: 60,
      );

      final cart = result.dataOrNull!;
      expect(cart.items, hasLength(1));
      expect(cart.items.single.quantity, AppConstants.maxCartQuantity);
    });

    test('keeps different sizes of the same product on separate lines', () async {
      await repository.addItem(buildProduct(), size: 'M');
      final result = await repository.addItem(buildProduct(), size: 'L');

      final cart = result.dataOrNull!;
      expect(cart.items, hasLength(2));
      expect(cart.items.map((item) => item.size), ['L', 'M']);
      expect(cart.itemCount, 2);
    });

    test('adds new items to the top of the cart', () async {
      await repository.addItem(buildProduct(id: 'first'), size: 'M');
      final result = await repository.addItem(
        buildProduct(id: 'second', title: 'Second'),
        size: 'M',
      );

      expect(result.dataOrNull!.items.first.product.id, 'second');
    });

    test('updates a quantity and removes the line at zero', () async {
      final added = await repository.addItem(buildProduct(), size: 'M');
      final key = added.dataOrNull!.items.single.key;

      final updated = await repository.updateQuantity(key, 4);
      expect(updated.dataOrNull!.items.single.quantity, 4);
      expect(updated.dataOrNull!.subtotal, closeTo(49.99 * 4, 0.0001));

      final removed = await repository.updateQuantity(key, 0);
      expect(removed.dataOrNull!.isEmpty, isTrue);
    });

    test('rejects updates for unknown cart lines', () async {
      final result = await repository.updateQuantity('missing::M', 2);

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, contains('no longer in your cart'));
    });

    test('removes a single line and clears the whole cart', () async {
      await repository.addItem(buildProduct(), size: 'M');
      final cart = (await repository.addItem(buildProduct(id: 'p2'), size: 'L'))
          .dataOrNull!;

      final afterRemove = await repository.removeItem(cart.items.first.key);
      expect(afterRemove.dataOrNull!.items, hasLength(1));

      final cleared = await repository.clear();
      expect(cleared.dataOrNull!.isEmpty, isTrue);
      expect((await repository.getCart()).dataOrNull!.isEmpty, isTrue);
    });

    test('maps corrupted local storage to a CacheFailure', () async {
      prefs = await createTestPreferences({
        AppConstants.cartStorageKey: 'not-a-json-list',
      });
      repository = buildRepository();

      final result = await repository.getCart();

      expect(result.failureOrNull, isA<CacheFailure>());
      expect(result.failureOrNull!.message, contains('Unable to read'));
    });
  });
}
