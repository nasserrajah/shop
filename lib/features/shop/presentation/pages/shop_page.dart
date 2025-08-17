// أضف هذا في أعلى الملف مع باقي الimports
import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shop/features/shop/presentation/pages/product_detail_page.dart';
import '../../domain/entities/product.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../widgets/banner_slider.dart';
import '../widgets/search_bar.dart';
import 'favorites_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';


class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  final List<Widget> _pages = const [
    HomeContent(),
    FavoritesPage(),
    CartPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider.value(
        value: BlocProvider.of<ShopBloc>(context),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            context.read<ShopBloc>().add(LoadFavoritesEvent());
          } else if (index == 0) {
            context.read<ShopBloc>().add(LoadShopEvent());
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        selectedItemColor: Color(0xFF6055D8),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),

    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildHeader(),
            const SizedBox(height: 16),
            const SearchBar(),
            const SizedBox(height: 16),
            const BannerSlider(),
            const SizedBox(height: 12),
            _buildCategoriesSection(context),
            const SizedBox(height: 16),
            _buildPopularProductsSection(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Hello!', style: TextStyle(color: Colors.grey)),
              Text('John William', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
            child: const Icon(Icons.notifications, color: Color(0xFF7C7979)),
          )
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is ShopError) {
              return Center(child: Text(state.message));
            }
            if (state is ShopLoaded) {
              final categories = _getUniqueCategories(state.products);
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: category.image,
                              height: 70,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: Colors.grey[200]),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.category, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildPopularProductsSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Most Popular', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is ShopError) {
              return Center(child: Text(state.message));
            }
            if (state is ShopLoaded) {
              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 170,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: product.image.isNotEmpty
                                        ? product.image
                                        : 'https://via.placeholder.com/300',
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(height: 140, color: Colors.grey[200]),
                                    errorWidget: (context, url, error) => Container(
                                      height: 140,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error_outline, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6055D8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: product.isFavorite ? Colors.red : Colors.white,
                              ),
                              onPressed: () {
                                context.read<ShopBloc>().add(ToggleFavoriteEvent(product.id));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  List<_Category> _getUniqueCategories(List<Product> products) {
    final Map<String, _Category> byName = {};
    for (final p in products) {
      final name = (p.category?.toString() ?? '').trim().isNotEmpty ? p.category.toString() : 'Other';
      byName.putIfAbsent(
        name,
            () => _Category(
          name: name,
          image: (p.image.isNotEmpty) ? p.image : 'https://via.placeholder.com/300',
        ),
      );
    }
    return byName.values.toList();
  }
}
class _Category {
  final String name;
  final String image;
  const _Category({required this.name, required this.image});
}
