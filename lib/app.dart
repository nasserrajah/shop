import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/orders/presentation/providers/order_providers.dart';
import 'features/products/presentation/providers/product_providers.dart';
import 'features/shell/presentation/app_shell.dart';
import 'features/shell/presentation/providers/navigation_providers.dart';

class ShopApp extends ConsumerWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: ref.watch(navigationBlocProvider)),
        BlocProvider.value(value: ref.watch(catalogBlocProvider)),
        BlocProvider.value(value: ref.watch(ordersBlocProvider)),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        themeAnimationDuration: const Duration(milliseconds: 220),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const AppShell(),
      ),
    );
  }
}
