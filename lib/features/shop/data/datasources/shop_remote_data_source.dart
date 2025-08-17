import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

abstract class ShopRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
  Future<List<ProductModel>> fetchFeaturedProducts();
  Future<List<String>> fetchCategories();
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final ApiClient apiClient;
  ShopRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final raw = await apiClient.get(ApiConstants.productsPath);
    return _parseProducts(raw);
  }

  @override
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    final raw = await apiClient.get(ApiConstants.featuredProductsPath);
    return _parseProducts(raw);
  }

  @override
  Future<List<String>> fetchCategories() async {
    final raw = await apiClient.get(ApiConstants.categoriesPath);
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    throw Exception('Unexpected categories payload');
  }

  List<ProductModel> _parseProducts(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (raw is Map && raw['products'] is List) {
      return (raw['products'] as List).map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Unexpected products payload');
  }
}