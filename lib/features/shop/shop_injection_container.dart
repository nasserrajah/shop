import 'package:get_it/get_it.dart';
import 'data/datasources/shop_remote_data_source.dart';
import 'data/repositories/shop_repository_impl.dart';
import 'domain/repositories/shop_repository.dart' hide ShopRepositoryImpl;
import 'domain/usecases/get_products.dart';
import 'domain/usecases/toggle_favorite.dart';
import 'presentation/bloc/shop_bloc.dart';
import '../../core/network/api_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => ApiClient());

  // Data sources
  sl.registerLazySingleton<ShopRemoteDataSource>(
        () => ShopRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ShopRepository>(
        () => ShopRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  // Bloc
  sl.registerLazySingleton(() => ShopBloc(
    getProducts: sl(),
    toggleFavorite: sl(),
    shopRepository: sl(),
  ));
}
