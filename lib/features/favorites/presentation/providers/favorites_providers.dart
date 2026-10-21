import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/result/result.dart';
import '../../../products/domain/entities/product.dart';
import '../../data/datasources/favorite_local_data_source.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/usecases/favorite_usecases.dart';

final favoriteLocalDataSourceProvider = Provider<FavoriteLocalDataSource>((ref) {
  return FavoriteLocalDataSourceImpl(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepositoryImpl(
    localDataSource: ref.watch(favoriteLocalDataSourceProvider),
  );
});

final getFavoritesProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.watch(favoriteRepositoryProvider));
});

final toggleFavoriteProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(favoriteRepositoryProvider));
});

/// Favorites are simple, read-mostly app state, so they are managed with
/// Riverpod. The repository is the single source of truth and persists every
/// mutation.
class FavoritesController extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    final result = await ref.watch(getFavoritesProvider)();
    return result.fold(
      onSuccess: (favorites) => favorites,
      onFailure: (failure) => throw failure,
    );
  }

  Future<Result<List<Product>>> toggle(Product product) async {
    final result = await ref.read(toggleFavoriteProvider)(product);
    result.fold(
      onSuccess: (favorites) => state = AsyncData(favorites),
      onFailure: (_) {},
    );
    return result;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getFavoritesProvider)();
      return result.fold(
        onSuccess: (favorites) => favorites,
        onFailure: (failure) => throw failure,
      );
    });
  }
}

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<Product>>(
  FavoritesController.new,
);

final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final favorites = ref.watch(favoritesControllerProvider).valueOrNull ?? const [];
  return favorites.any((product) => product.id == productId);
});

final favoriteCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesControllerProvider).valueOrNull?.length ?? 0;
});
