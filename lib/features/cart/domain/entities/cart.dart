import 'package:equatable/equatable.dart';

import 'cart_item.dart';

class Cart extends Equatable {
  const Cart({this.items = const []});

  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  int get itemCount =>
      items.fold(0, (total, item) => total + item.quantity);

  int get lineCount => items.length;

  double get subtotal =>
      items.fold(0, (total, item) => total + item.lineTotal);

  int quantityFor(String key) {
    for (final item in items) {
      if (item.key == key) return item.quantity;
    }
    return 0;
  }

  bool containsProduct(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  Cart copyWith({List<CartItem>? items}) {
    return Cart(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
