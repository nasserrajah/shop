import 'package:flutter_test/flutter_test.dart';
import 'package:shop/core/constants/app_constants.dart';
import 'package:shop/core/error/exceptions.dart';
import 'package:shop/core/error/failures.dart';
import 'package:shop/features/products/data/models/category_model.dart';
import 'package:shop/features/products/data/models/product_model.dart';
import 'package:shop/features/products/data/repositories/product_repository_impl.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  ProductModel model(String id) {
    return ProductModel.fromEntity(
      buildProduct(id: id, title: 'Product $id', price: 10),
    );
  }

  group('ProductRepositoryImpl', () {
    test('caches the catalogue until a forced refresh', () async {
      final remote = FakeProductRemoteDataSource(
        products: [model('1'), model('2')],
      );
      final repository = ProductRepositoryImpl(remoteDataSource: remote);

      final first = await repository.getProducts();
      final second = await repository.getProducts();

      expect(first.dataOrNull, hasLength(2));
      expect(second.dataOrNull, hasLength(2));
      expect(remote.productsCalls, 1);

      final refreshed = await repository.getProducts(forceRefresh: true);

      expect(refreshed.dataOrNull, hasLength(2));
      expect(remote.productsCalls, 2);
    });

    test('maps remote failures to domain failures', () async {
      final repository = ProductRepositoryImpl(
        remoteDataSource: FakeProductRemoteDataSource(
          productsError: const NetworkException('No internet'),
        ),
      );

      final result = await repository.getProducts();

      expect(result.failureOrNull, isA<NetworkFailure>());
      expect(result.failureOrNull!.message, 'No internet');
    });

    test('limits featured products', () async {
      final remote = FakeProductRemoteDataSource(
        products: List.generate(
          AppConstants.featuredProductsLimit + 4,
          (index) => model('$index'),
        ),
      );
      final repository = ProductRepositoryImpl(remoteDataSource: remote);

      final result = await repository.getFeaturedProducts();

      expect(result.dataOrNull, hasLength(AppConstants.featuredProductsLimit));
    });

    test('resolves products from the cache without another request', () async {
      final remote = FakeProductRemoteDataSource(products: [model('1')]);
      final repository = ProductRepositoryImpl(remoteDataSource: remote);
      await repository.getProducts();

      final result = await repository.getProductById('1');

      expect(result.dataOrNull!.id, '1');
      expect(remote.productsCalls, 1);
    });

    test('refreshes the catalogue and reports missing products', () async {
      final remote = FakeProductRemoteDataSource(products: [model('1')]);
      final repository = ProductRepositoryImpl(remoteDataSource: remote);
      await repository.getProducts();

      final result = await repository.getProductById('missing');

      expect(result.failureOrNull, isA<NotFoundFailure>());
      expect(remote.productsCalls, 2);
    });

    test('returns categories from the remote data source', () async {
      final remote = FakeProductRemoteDataSource(
        categories: const [
          CategoryModel(id: 'c1', name: 'Shoes', image: ''),
        ],
      );
      final repository = ProductRepositoryImpl(remoteDataSource: remote);

      final result = await repository.getCategories();

      expect(result.dataOrNull!.single.name, 'Shoes');
    });
  });
}
