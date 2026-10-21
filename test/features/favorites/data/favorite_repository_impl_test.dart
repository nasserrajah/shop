import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/core/constants/app_constants.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/favorites/data/datasources/favorite_local_data_source.dart';
import 'package:shop/features/favorites/data/repositories/favorite_repository_impl.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FavoriteRepositoryImpl repository;

  FavoriteRepositoryImpl buildRepository(SharedPreferences prefs) {
    return FavoriteRepositoryImpl(
      localDataSource: FavoriteLocalDataSourceImpl(prefs: prefs),
    );
  }

  group('FavoriteRepositoryImpl', () {
    setUp(() async {
      final prefs = await createTestPreferences();
      repository = buildRepository(prefs);
    });

    test('starts with no favorites', () async {
      final result = await repository.getFavorites();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('toggles a favorite on and off', () async {
      final product = buildProduct();

      final added = await repository.toggleFavorite(product);
      expect(added.dataOrNull!.map((item) => item.id), ['p1']);
      expect((await repository.isFavorite('p1')).dataOrNull, isTrue);

      final removed = await repository.toggleFavorite(product);
      expect(removed.dataOrNull, isEmpty);
      expect((await repository.isFavorite('p1')).dataOrNull, isFalse);
    });

    test('keeps the newest favorite first', () async {
      await repository.toggleFavorite(buildProduct(id: 'first'));
      final result = await repository.toggleFavorite(
        buildProduct(id: 'second', title: 'Second'),
      );

      expect(result.dataOrNull!.map((item) => item.id), ['second', 'first']);
    });

    test('persists favorites across repository instances', () async {
      final prefs = await createTestPreferences();
      await buildRepository(prefs).toggleFavorite(buildProduct());

      final reloaded = await buildRepository(prefs).getFavorites();

      expect(reloaded.dataOrNull!.single.id, 'p1');
      expect(reloaded.dataOrNull!.single.title, 'Running Shoes');
    });

    test('clears all favorites', () async {
      await repository.toggleFavorite(buildProduct());
      await repository.toggleFavorite(buildProduct(id: 'p2'));

      final cleared = await repository.clearFavorites();

      expect(cleared.isSuccess, isTrue);
      expect((await repository.getFavorites()).dataOrNull, isEmpty);
    });

    test('maps corrupted local storage to a CacheFailure', () async {
      final prefs = await createTestPreferences({
        AppConstants.favoritesStorageKey: 'not-json',
      });

      final result = await buildRepository(prefs).getFavorites();

      expect(result.failureOrNull, isA<CacheFailure>());
    });
  });
}
