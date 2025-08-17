import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int selectedIndex = 0; // 0=Active, 1=Completed, 2=Cancel

  @override
  void initState() {
    super.initState();
    context.read<ShopBloc>().add(LoadOrdersEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ["Active", "Completed", "Cancel"];
    final purple = const Color(0xFF6055D8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Orders", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedIndex = index),
                child: Column(
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isSelected)
                      Container(
                        height: 2,
                        width: 40,
                        color: purple,
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: BlocConsumer<ShopBloc, ShopState>(
              listenWhen: (prev, curr) => curr is ShopError,
              listener: (context, state) {
                if (state is ShopError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              buildWhen: (prev, curr) => curr is OrdersLoaded || curr is ShopError,
              builder: (context, state) {
                if (state is OrdersLoaded) {
                  final filteredOrders = state.orders.where((order) {
                    if (selectedIndex == 0) return order.status == "Active";
                    if (selectedIndex == 1) return order.status == "Completed";
                    return order.status == "Cancel";
                  }).toList();

                  if (filteredOrders.isEmpty) {
                    return const Center(child: Text("No orders yet"));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ShopBloc>().add(LoadOrdersEvent());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (_, i) => _buildOrderCard(filteredOrders[i]),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          )

        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final purple = const Color(0xFF6055D8);
    final first = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (first != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                first.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order #${order.id.substring(order.id.length - 4)}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("${order.items.length} items",
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Text("\$${order.total.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: purple)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Track Order",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        ],
      ),
    );
  }
}