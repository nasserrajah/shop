import 'package:flutter/material.dart';

import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/help_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/shell/presentation/app_shell.dart';

abstract final class AppRoutes {
  static const String shell = '/';
  static const String products = '/products';
  static const String product = '/product';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/details';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String help = '/help';
}

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.products:
        return _page(const ProductsPage(), settings);
      case AppRoutes.product:
        final productId = settings.arguments;
        if (productId is String && productId.isNotEmpty) {
          return _page(
            ProductDetailPage(productId: productId),
            settings,
          );
        }
        return _page(const ProductsPage(), settings);
      case AppRoutes.cart:
        return _page(const CartPage(showBackButton: true), settings);
      case AppRoutes.checkout:
        return _page(const CheckoutPage(), settings);
      case AppRoutes.orders:
        return _page(const OrdersPage(), settings);
      case AppRoutes.orderDetails:
        final orderId = settings.arguments;
        if (orderId is String && orderId.isNotEmpty) {
          return _page(OrderDetailPage(orderId: orderId), settings);
        }
        return _page(const OrdersPage(), settings);
      case AppRoutes.editProfile:
        return _page(const EditProfilePage(), settings);
      case AppRoutes.settings:
        return _page(const SettingsPage(), settings);
      case AppRoutes.help:
        return _page(const HelpPage(), settings);
      case AppRoutes.shell:
      default:
        return _page(const AppShell(), settings);
    }
  }

  static MaterialPageRoute<T> _page<T>(Widget child, RouteSettings settings) {
    return MaterialPageRoute<T>(
      settings: settings,
      builder: (_) => child,
    );
  }

  static Future<T?> pushProducts<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.products);
  }

  static Future<T?> pushProductDetails<T>(
    BuildContext context,
    String productId,
  ) {
    return Navigator.of(context).pushNamed<T>(
      AppRoutes.product,
      arguments: productId,
    );
  }

  static Future<T?> pushCart<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.cart);
  }

  static Future<T?> pushCheckout<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.checkout);
  }

  static Future<T?> pushOrders<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.orders);
  }

  static Future<T?> replaceWithOrders<T>(BuildContext context) {
    return Navigator.of(context).pushReplacementNamed<T, dynamic>(
      AppRoutes.orders,
    );
  }

  static Future<T?> pushOrderDetails<T>(BuildContext context, String orderId) {
    return Navigator.of(context).pushNamed<T>(
      AppRoutes.orderDetails,
      arguments: orderId,
    );
  }

  static Future<T?> pushEditProfile<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.editProfile);
  }

  static Future<T?> pushSettings<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.settings);
  }

  static Future<T?> pushHelp<T>(BuildContext context) {
    return Navigator.of(context).pushNamed<T>(AppRoutes.help);
  }
}
