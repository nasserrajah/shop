import 'package:equatable/equatable.dart';
import 'package:shop/features/shop/domain/entities/product.dart';

import '../../domain/entities/order.dart';

abstract class ShopState extends Equatable {
  const ShopState();
}

class ShopInitial extends ShopState {
  @override
  List<Object> get props => [];
}

class ShopLoading extends ShopState {
  @override
  List<Object> get props => [];
}

class ShopLoaded extends ShopState {
  final List<Product> products;
  const ShopLoaded(this.products);
  @override
  List<Object> get props => [products];
}

class FavoritesLoading extends ShopState {
  @override
  List<Object> get props => [];
}

class FavoritesLoaded extends ShopState {
  final List<Product> favorites;
  const FavoritesLoaded(this.favorites);
  @override
  List<Object> get props => [favorites];
}

class CartLoading extends ShopState {
  @override
  List<Object> get props => [];
}

class CartLoaded extends ShopState {
  final List<Product> cartItems;
  final Map<String, int> quantities;
  final double total;

  const CartLoaded({
    required this.cartItems,
    required this.quantities,
    required this.total,
  });

  @override
  List<Object> get props => [cartItems, quantities, total];
}

class ShopError extends ShopState {
  final String message;
  const ShopError(this.message);
  @override
  List<Object> get props => [message];
}

class OrdersLoaded extends ShopState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}
