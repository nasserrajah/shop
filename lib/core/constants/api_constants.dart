/// Centralised HTTP configuration for the shop API.
class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://backend-course-6tuu.onrender.com';
  static const String productsPath = '/api/products';
  static const String featuredProductsPath = '/api/products/featured';
  static const String categoriesPath = '/api/Categories';

  static const Duration requestTimeout = Duration(seconds: 25);
}
