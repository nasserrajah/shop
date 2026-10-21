import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/presentation/pages/cart_page.dart';
import '../../cart/presentation/providers/cart_providers.dart';
import '../../favorites/presentation/pages/favorites_page.dart';
import '../../products/presentation/pages/home_page.dart';
import '../../profile/presentation/pages/profile_page.dart';
import 'bloc/navigation_bloc.dart';
import 'bloc/navigation_event.dart';
import 'bloc/navigation_state.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return PopScope(
          canPop: state.isHome,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              context.read<NavigationBloc>().add(const NavigateTo(0));
            }
          },
          child: Scaffold(
            body: IndexedStack(
              index: state.index,
              children: const [
                HomePage(),
                FavoritesPage(),
                CartPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: _AppBottomNavigation(
              currentIndex: state.index,
              onSelect: (index) =>
                  context.read<NavigationBloc>().add(NavigateTo(index)),
            ),
          ),
        );
      },
    );
  }
}

class _AppBottomNavigation extends ConsumerWidget {
  const _AppBottomNavigation({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemCountProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onSelect,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          activeIcon: Icon(Icons.favorite_rounded),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text(cartCount > 99 ? '99+' : '$cartCount'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          activeIcon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text(cartCount > 99 ? '99+' : '$cartCount'),
            child: const Icon(Icons.shopping_bag_rounded),
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedFontSize: 0,
      unselectedFontSize: 0,
    );
  }
}
