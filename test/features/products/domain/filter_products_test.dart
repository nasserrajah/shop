import 'package:flutter_test/flutter_test.dart';
import 'package:shop/features/products/domain/entities/product_sort_option.dart';
import 'package:shop/features/products/domain/usecases/filter_products.dart';

import '../../../helpers/test_fixtures.dart';

void main() {
  const filter = FilterProducts();

  final shoes = buildProduct(
    id: '1',
    title: 'Running Shoes',
    price: 80,
    category: 'shoes',
    description: 'Lightweight trainers',
    rating: 4.2,
    reviews: 10,
  );
  final jacket = buildProduct(
    id: '2',
    title: 'Winter Jacket',
    price: 120,
    category: 'winter',
    description: 'Warm and waterproof',
    rating: 4.8,
    reviews: 4,
  );
  final sandals = buildProduct(
    id: '3',
    title: 'Summer Sandals',
    price: 30,
    category: 'summer',
    description: 'Breathable footwear',
    rating: 4.8,
    reviews: 90,
  );
  final products = [shoes, jacket, sandals];

  group('FilterProducts', () {
    test('returns every product with default arguments', () {
      final result = filter(products: products);

      expect(result, products);
    });

    test('matches the query against title, category and description', () {
      expect(
        filter(products: products, query: 'RUNNING').map((p) => p.id),
        ['1'],
      );
      expect(
        filter(products: products, query: 'winter').map((p) => p.id),
        ['2'],
      );
      expect(
        filter(products: products, query: 'footwear').map((p) => p.id),
        ['3'],
      );
      expect(filter(products: products, query: 'nothing'), isEmpty);
    });

    test('filters by normalized category', () {
      expect(
        filter(products: products, category: '  SUMMER ').map((p) => p.id),
        ['3'],
      );
      expect(
        filter(products: products, category: '').length,
        products.length,
      );
    });

    test('combines query and category filters', () {
      expect(
        filter(products: products, query: 'sandals', category: 'summer'),
        [sandals],
      );
      expect(
        filter(products: products, query: 'sandals', category: 'winter'),
        isEmpty,
      );
    });

    test('sorts by price in both directions', () {
      final cheapestFirst = filter(
        products: products,
        sort: ProductSortOption.priceLowToHigh,
      );
      final priciestFirst = filter(
        products: products,
        sort: ProductSortOption.priceHighToLow,
      );

      expect(cheapestFirst.map((p) => p.id), ['3', '1', '2']);
      expect(priciestFirst.map((p) => p.id), ['2', '1', '3']);
    });

    test('sorts by rating then review count', () {
      final result = filter(products: products, sort: ProductSortOption.topRated);

      expect(result.map((p) => p.id), ['3', '2', '1']);
    });

    test('keeps the original order for the featured option', () {
      final result = filter(products: products, sort: ProductSortOption.featured);

      expect(result.map((p) => p.id), ['1', '2', '3']);
    });
  });
}
