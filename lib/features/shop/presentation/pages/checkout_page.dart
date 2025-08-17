import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import 'orders_page.dart';

enum PaymentMethod { paypal, card, cash }

class CheckoutPage extends StatefulWidget {
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;

  const CheckoutPage({
    super.key,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod selected = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6055D8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Check Out', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _InfoRow(
                iconBg: const Color(0xFFF1F3FF),
                icon: Icons.location_on,
                iconColor: purple,
                title: '325 15th Eighth Avenue, NewYork',
                subtitle: 'Saepe eaque fugiat ea voluptatum veniam.',
              ),
              const SizedBox(height: 12),
              _InfoRow(
                iconBg: const Color(0xFFEFF7FF),
                icon: Icons.access_time_filled,
                iconColor: purple,
                title: '6:00 pm, Wednesday 20',
                subtitle: '',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    _row('Items', widget.itemsCount.toString()),
                    _row('Subtotal', '\$${widget.subtotal.toStringAsFixed(0)}'),
                    _row('Discount', '\$${widget.discount.toStringAsFixed(0)}'),
                    _row('Delivery', '\$${widget.delivery.toStringAsFixed(0)}'),
                    const Divider(height: 20, thickness: 1),
                    _row('Total', '\$${widget.total.toStringAsFixed(0)}',
                        bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Choose payment method',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _paymentTile('Paypal', '🅿️', PaymentMethod.paypal, purple),
              _paymentTile('Credit Card', '💳', PaymentMethod.card, purple),
              _paymentTile('Cash', '🪙', PaymentMethod.cash, purple),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              final bloc = context.read<ShopBloc>();
              if (bloc.state is CartLoaded) {
                final cartState = bloc.state as CartLoaded;
                bloc.add(PlaceOrderEvent(
                  cartState.cartItems,
                  cartState.total,
                ));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              }
            },
            child: const Text('Check Out',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(
      String title, String leading, PaymentMethod value, Color purple) {
    final isSelected = selected == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => setState(() => selected = value),
      leading: Text(leading, style: const TextStyle(fontSize: 20)),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected ? purple : Colors.black12, width: 2),
          color: isSelected ? purple : Colors.transparent,
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Text(v,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: bold ? const Color(0xFF6055D8) : Colors.black)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: iconBg,
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }
}
