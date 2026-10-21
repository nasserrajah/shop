import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _faqs = [
    (
      'How do I track my order?',
      'Open Profile → My orders, choose the order and open Tracking to see its current stage. Orders are stored on this device so tracking works offline.',
    ),
    (
      'Can I cancel an order?',
      'Yes. Active orders can be cancelled from the order card or the order details screen. Cancelling keeps the order in your history.',
    ),
    (
      'What payment methods do you support?',
      'PayPal, credit card and cash on delivery. Card details are never stored; the form only validates the values you type.',
    ),
    (
      'How do returns work?',
      'Products can be returned within 14 days of delivery. Contact support and include your order number so we can help quickly.',
    ),
    (
      'Where is my data stored?',
      'Favorites, cart items, orders and your profile are saved locally with shared preferences. Nothing is sent to a server except product catalogue requests.',
    ),
  ];

  Future<void> _copy(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    showAppSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent_rounded, color: Colors.white, size: 30),
                SizedBox(height: 10),
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Find quick answers below or reach out to our team.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Frequently asked questions',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                for (var index = 0; index < _faqs.length; index++) ...[
                  ExpansionTile(
                    shape: const Border(),
                    collapsedShape: const Border(),
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.question_mark_rounded,
                        size: 16,
                        color: scheme.primary,
                      ),
                    ),
                    title: Text(
                      _faqs[index].$1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _faqs[index].$2,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (index != _faqs.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Contact us',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _ContactTile(
            icon: Icons.mail_outline_rounded,
            title: 'support@eightshop.dev',
            subtitle: 'We reply within one business day',
            color: AppColors.primary,
            onTap: () => _copy(
              context,
              'support@eightshop.dev',
              'Support email copied',
            ),
          ),
          const SizedBox(height: 8),
          _ContactTile(
            icon: Icons.phone_outlined,
            title: '+1 (555) 010-2040',
            subtitle: 'Monday - Friday, 9am - 6pm',
            color: AppColors.success,
            onTap: () => _copy(
              context,
              '+1 (555) 010-2040',
              'Phone number copied',
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.copy_rounded, size: 18),
      ),
    );
  }
}
