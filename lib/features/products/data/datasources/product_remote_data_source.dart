import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();

  Future<List<ProductModel>> fetchFeaturedProducts();

  Future<List<CategoryModel>> fetchCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final raw = await _apiClient.getJson(ApiConstants.productsPath);
    return _parseProducts(raw);
  }

  @override
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final raw = await _apiClient.getJson(ApiConstants.featuredProductsPath);
    return _parseProducts(raw);
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final raw = await _apiClient.getJson(ApiConstants.categoriesPath);
    final items = _extractList(raw, what: 'categories');
    try {
      return items
          .map((item) => CategoryModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } on Object {
      throw const ParsingException('Unable to read the categories response.');
    }
  }

  List<ProductModel> _parseProducts(dynamic raw) {
    final items = _extractList(raw, what: 'products');
    try {
      return items
          .map((item) => ProductModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    } on Object {
      throw const ParsingException('Unable to read the products response.');
    }
  }

  List<dynamic> _extractList(dynamic raw, {required String what}) {
    if (raw is List) return raw;

    if (raw is Map) {
      const candidateKeys = ['data', 'products', 'categories', 'items', 'results'];
      for (final key in candidateKeys) {
        final value = raw[key];
        if (value is List) return value;
        if (value is Map) {
          final nested = _tryExtract(value);
          if (nested != null) return nested;
        }
      }
      final nested = _tryExtract(raw);
      if (nested != null) return nested;
    }

    throw ParsingException('Unexpected $what response format.');
  }

  List<dynamic>? _tryExtract(Map<dynamic, dynamic> map) {
    for (final value in map.values) {
      if (value is List) return value;
    }
    return null;
  }
}
