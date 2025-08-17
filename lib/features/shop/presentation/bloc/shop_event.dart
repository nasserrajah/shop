import 'package:equatable/equatable.dart';
import 'package:shop/features/shop/domain/entities/product.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();
}

class LoadShopEvent extends ShopEvent {
  @override
  List<Object> get props => [];
}

class ToggleFavoriteEvent extends ShopEvent {
  final String productId;
  const ToggleFavoriteEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class LoadFavoritesEvent extends ShopEvent {
  @override
  List<Object> get props => [];
}

class LoadCartEvent extends ShopEvent {
  @override
  List<Object> get props => [];
}

class AddToCartEvent extends ShopEvent {
  final Product product;
  const AddToCartEvent(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveFromCartEvent extends ShopEvent {
  final String productId;
  const RemoveFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class IncreaseQuantityEvent extends ShopEvent {
  final String productId;
  const IncreaseQuantityEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class DecreaseQuantityEvent extends ShopEvent {
  final String productId;
  const DecreaseQuantityEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class ClearCartEvent extends ShopEvent {
  @override
  List<Object> get props => [];
}

class PlaceOrderEvent extends ShopEvent {
  final List<Product> items;
  final double total;
  const PlaceOrderEvent(this.items, this.total);

  @override
  List<Object> get props => [items, total];
}

class LoadOrdersEvent extends ShopEvent {
  @override
  List<Object> get props => [];
}
