import 'package:bloc/bloc.dart';
import 'package:shop/features/shop/presentation/bloc/shop_event.dart';
import 'package:shop/features/shop/presentation/bloc/shop_state.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../domain/entities/order.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetProducts getProducts;
  final ToggleFavorite toggleFavorite;
  final ShopRepository shopRepository;

  final List<Product> _cartItems = [];
  final Map<String, int> _productQuantities = {};
  final Map<String, Product> _productDetails = {};

  Map<String, int> get productQuantities => Map.from(_productQuantities);
  final List<Order> _orders = [];

  ShopBloc({
    required this.getProducts,
    required this.toggleFavorite,
    required this.shopRepository,
  }) : super(ShopInitial()) {
    on<LoadShopEvent>(_onLoadShop);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<IncreaseQuantityEvent>(_onIncreaseQuantity);
    on<DecreaseQuantityEvent>(_onDecreaseQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<PlaceOrderEvent>(_onPlaceOrder);
    on<LoadOrdersEvent>(_onLoadOrders);
  }

  double get _calculateTotal {
    return _cartItems.fold(0, (sum, item) {
      final quantity = _productQuantities[item.id] ?? 1;
      return sum + (item.price * quantity);
    });
  }

  Future<void> _onLoadShop(
      LoadShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final products = await getProducts.call();
      for (var product in products) {
        _productDetails[product.id] = product;
      }
      emit(ShopLoaded(products));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<ShopState> emit) async {
    try {
      await toggleFavorite.call(event.productId);

      if (state is ShopLoaded) {
        final currentState = state as ShopLoaded;
        final updatedProducts = currentState.products.map((product) {
          return product.id == event.productId
              ? product.copyWith(isFavorite: !product.isFavorite)
              : product;
        }).toList();
        emit(ShopLoaded(updatedProducts));
      }

      if (state is FavoritesLoaded) {
        final favorites = await shopRepository.getFavoriteProducts();
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      emit(ShopError('Failed to toggle favorite: ${e.toString()}'));
    }
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event, Emitter<ShopState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await shopRepository.getFavoriteProducts();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  Future<void> _onLoadCart(
      LoadCartEvent event, Emitter<ShopState> emit) async {
    emit(CartLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: _calculateTotal,
      ));
    } catch (e) {
      emit(ShopError('Failed to load cart: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCart(
      AddToCartEvent event, Emitter<ShopState> emit) async {
    try {
      if (!_cartItems.any((item) => item.id == event.product.id)) {
        _cartItems.add(event.product);
        _productQuantities[event.product.id] = 1;
      } else {
        _productQuantities[event.product.id] =
            (_productQuantities[event.product.id] ?? 0) + 1;
      }
      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: _calculateTotal,
      ));
    } catch (e) {
      emit(ShopError('Failed to add to cart: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCartEvent event, Emitter<ShopState> emit) async {
    try {
      _cartItems.removeWhere((item) => item.id == event.productId);
      _productQuantities.remove(event.productId);
      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: _calculateTotal,
      ));
    } catch (e) {
      emit(ShopError('Failed to remove from cart: ${e.toString()}'));
    }
  }

  Future<void> _onIncreaseQuantity(
      IncreaseQuantityEvent event, Emitter<ShopState> emit) async {
    try {
      _productQuantities.update(
        event.productId,
            (value) => value + 1,
        ifAbsent: () => 1,
      );
      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: _calculateTotal,
      ));
    } catch (e) {
      emit(ShopError('Failed to increase quantity: ${e.toString()}'));
    }
  }

  Future<void> _onDecreaseQuantity(
      DecreaseQuantityEvent event, Emitter<ShopState> emit) async {
    try {
      final currentQuantity = _productQuantities[event.productId] ?? 1;
      if (currentQuantity > 1) {
        _productQuantities[event.productId] = currentQuantity - 1;
      } else {
        _cartItems.removeWhere((item) => item.id == event.productId);
        _productQuantities.remove(event.productId);
      }
      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: _calculateTotal,
      ));
    } catch (e) {
      emit(ShopError('Failed to decrease quantity: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(
      ClearCartEvent event, Emitter<ShopState> emit) async {
    try {
      _cartItems.clear();
      _productQuantities.clear();
      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: _calculateTotal,
      ));
    } catch (e) {
      emit(ShopError('Failed to clear cart: ${e.toString()}'));
    }
  }

  Future<void> _onPlaceOrder(
      PlaceOrderEvent event, Emitter<ShopState> emit) async {
    try {
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: event.items,
        total: event.total,
        status: "Active",
      );

      await shopRepository.saveOrder(order);

      _orders.add(order);
      _cartItems.clear();
      _productQuantities.clear();


      emit(CartLoaded(
        cartItems: List.from(_cartItems),
        quantities: Map.from(_productQuantities),
        total: 0,
      ));


      emit(OrdersLoaded(List.from(_orders)));
    } catch (e) {
      emit(ShopError('Failed to place order: ${e.toString()}'));
    }
  }

  Future<void> _onLoadOrders(
      LoadOrdersEvent event, Emitter<ShopState> emit) async {
    try {
      final orders = await shopRepository.getOrders();
      _orders.clear();
      _orders.addAll(orders);
      emit(OrdersLoaded(List.from(_orders)));
    } catch (e) {
      emit(ShopError('Failed to load orders: ${e.toString()}'));
    }
  }
}
