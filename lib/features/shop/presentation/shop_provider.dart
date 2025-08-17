// import 'package:flutter/widgets.dart';
// import 'bloc/shop_bloc.dart';
//
//
// class ShopProvider extends InheritedWidget {
//   final ShopBloc shopBloc;
//   const ShopProvider({required this.shopBloc, required super.child, super.key});
//
//   static ShopProvider? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShopProvider>();
//
//   @override
//   bool updateShouldNotify(covariant ShopProvider oldWidget) => shopBloc != oldWidget.shopBloc;
// }