import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/shop/shop_injection_container.dart' as di;
import 'features/shop/presentation/pages/shop_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ShopBloc>(), // الحصول على Bloc من GetIt
      child: MaterialApp(
        title: 'Eight Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const ShopPage(),
      ),
    );
  }
}
