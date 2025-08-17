import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/shop/presentation/pages/shop_page.dart';
import '../../domain/entities/product.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ShopPage()),
                  (route) => false,
            );
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),

      body: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            return _buildCartContent(context, state.cartItems);
          } else if (state is ShopError) {
            return Center(child: Text(state.message));
          } else {
            context.read<ShopBloc>().add(LoadCartEvent());
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear Cart'),
              onTap: () {
                context.read<ShopBloc>().add(ClearCartEvent());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cart Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCartContent(BuildContext context, List<Product> cartItems) {
    final bloc = context.read<ShopBloc>();
    final quantities = bloc.productQuantities;

    double subtotal = cartItems.fold(0, (sum, item) {
      final quantity = quantities[item.id] ?? 1;
      return sum + (item.price * quantity);
    });

    double discount = 4.0;
    double delivery = 2.0;
    double total = subtotal - discount + delivery;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems[index];
              final quantity = quantities[product.id] ?? 1;
              return _buildCartItem(
                context,
                product: product,
                quantity: quantity,
              );
            },
          ),
        ),

        _buildOrderSummary(
          context,
          itemsCount: cartItems.length,
          subtotal: subtotal,
          discount: discount,
          delivery: delivery,
          total: total,
        ),
      ],
    );
  }


  Widget _buildCartItem(
      BuildContext context, {
        required Product product,
        required int quantity,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF6055D8),
                  ),
                ),
              ],
            ),
          ),


          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 28),
                onPressed: () {
                  context.read<ShopBloc>().add(RemoveFromCartEvent(product.id));
                },
              ),
              const SizedBox(height: 12),


              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallCircleButton(
                    icon: Icons.remove,
                    onPressed: () {
                      if (quantity > 1) {
                        context.read<ShopBloc>().add(DecreaseQuantityEvent(product.id));
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    quantity.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildSmallCircleButton(
                    icon: Icons.add,
                    onPressed: () {
                      context.read<ShopBloc>().add(IncreaseQuantityEvent(product.id));
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildSmallCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF6055D8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 14, color: Colors.white),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildOrderSummary(
      BuildContext context, {
        required int itemsCount,
        required double subtotal,
        required double discount,
        required double delivery,
        required double total,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow('Items', itemsCount.toString()),
          _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(0)}'),
          _buildSummaryRow('Discount', '\$${discount.toStringAsFixed(0)}'),
          _buildSummaryRow('Delivery Charges', '\$${delivery.toStringAsFixed(0)}'),
          const Divider(height: 20, thickness: 1),
          _buildSummaryRow(
            'Total',
            '\$${total.toStringAsFixed(0)}',
            isTotal: true,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6055D8),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      itemsCount: itemsCount,
                      subtotal: subtotal,
                      discount: discount,
                      delivery: delivery,
                      total: total,
                    ),
                  ),
                );
              },
              child: const Text(
                'Check Out',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF6055D8) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
