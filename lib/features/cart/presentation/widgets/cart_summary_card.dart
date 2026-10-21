import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../checkout/domain/entities/checkout_summary.dart';

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    super.key,
    required this.summary,
    required this.onCheckout,
  });

  final CheckoutSummary summary;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Items', value: '${summary.itemsCount}'),
          _SummaryRow(
            label: 'Subtotal',
            value: formatCurrency(summary.subtotal),
          ),
          _SummaryRow(
            label: 'Discount',
            value: '-${formatCurrency(summary.discount)}',
            valueColor: scheme.primary,
          ),
          _SummaryRow(
            label: 'Delivery',
            value: formatCurrency(summary.delivery),
          ),
          const Divider(height: 22),
          _SummaryRow(
            label: 'Total',
            value: formatCurrency(summary.total),
            bold: true,
            valueColor: scheme.primary,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheckout,
              child: const Text('Check out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(
      fontSize: bold ? 16 : 13,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: bold ? null : scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value,
            style: style.copyWith(
              color: valueColor ?? scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
