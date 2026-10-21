/// Application-wide business defaults and local storage keys.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Eight Shop';
  static const String appVersion = '2.0.0';

  static const double discountAmount = 4.0;
  static const double deliveryFee = 2.0;
  static const int maxCartQuantity = 99;
  static const int featuredProductsLimit = 8;

  static const String favoritesStorageKey = 'shop.favorites.v1';
  static const String cartStorageKey = 'shop.cart.v1';
  static const String ordersStorageKey = 'shop.orders.v1';
  static const String profileStorageKey = 'shop.profile.v1';
  static const String themeStorageKey = 'shop.theme.v1';
}
