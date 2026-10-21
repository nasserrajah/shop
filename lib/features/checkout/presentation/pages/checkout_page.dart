import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/entities/payment_method.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../../orders/presentation/bloc/orders_event.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/checkout_summary.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../providers/checkout_providers.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => CheckoutBloc(
        getCart: ref.read(getCartProvider),
        submitOrder: ref.read(submitOrderProvider),
      ),
      child: const _CheckoutView(),
    );
  }
}

class _CheckoutView extends ConsumerStatefulWidget {
  const _CheckoutView();

  @override
  ConsumerState<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<_CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _paypalController = TextEditingController();

  late final List<DateTime> _deliverySlots;
  late DateTime _selectedDelivery;
  bool _navigatedAfterSuccess = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).valueOrNull;
    _addressController.text = profile != null && profile.address.isNotEmpty
        ? profile.address
        : UserProfile.demo().address;
    _deliverySlots = _buildDeliverySlots();
    _selectedDelivery = _deliverySlots.first;
  }

  List<DateTime> _buildDeliverySlots() {
    final now = DateTime.now();
    final first = now.add(const Duration(hours: 2));
    final roundedFirst = DateTime(
      first.year,
      first.month,
      first.day,
      first.hour,
      first.minute < 30 ? 30 : 0,
    ).add(first.minute < 30 ? Duration.zero : const Duration(hours: 1));

    return [
      roundedFirst,
      roundedFirst.add(const Duration(hours: 3)),
      DateTime(now.year, now.month, now.day + 1, 10),
    ];
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _paypalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<CheckoutBloc>().add(
          CheckoutSubmitted(
            address: _addressController.text,
            deliveryTime: _selectedDelivery,
          ),
        );
  }

  Future<void> _handleSuccess(Order order) async {
    if (_navigatedAfterSuccess) return;
    _navigatedAfterSuccess = true;

    await ref.read(cartControllerProvider.notifier).refresh();
    if (!mounted) return;
    context.read<OrdersBloc>().add(const LoadOrdersEvent());

    showAppSnackBar(
      context,
      'Order #${formatShortOrderId(order.id)} placed successfully!',
    );
    await AppRouter.replaceWithOrders(context);
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(checkoutSummaryProvider);

    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.status == CheckoutStatus.success && state.order != null) {
          _handleSuccess(state.order!);
        } else if (state.status == CheckoutStatus.failure &&
            state.errorMessage != null) {
          showAppSnackBar(context, state.errorMessage!, isError: true);
        }
      },
      child: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (summary.isEmpty &&
              state.status != CheckoutStatus.submitting &&
              state.status != CheckoutStatus.success) {
            return Scaffold(
              appBar: AppBar(title: const Text('Check out')),
              body: AppEmptyView(
                title: 'Nothing to check out',
                message: 'Add a few products to your cart first.',
                icon: Icons.shopping_bag_outlined,
                actionLabel: 'Back to cart',
                onAction: () => Navigator.of(context).pop(),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Check out')),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  _SectionCard(
                    title: 'Delivery address',
                    icon: Icons.location_on_outlined,
                    child: TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      minLines: 2,
                      maxLines: 3,
                      validator: Validators.address,
                      decoration: const InputDecoration(
                        hintText: 'Street, building, city, postal code',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Delivery time',
                    icon: Icons.schedule_rounded,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final slot in _deliverySlots)
                          ChoiceChip(
                            label: Text(
                              '${formatDate(slot)} • ${formatTime(slot)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: _selectedDelivery == slot,
                            showCheckmark: false,
                            onSelected: (_) =>
                                setState(() => _selectedDelivery = slot),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Payment method',
                    icon: Icons.credit_card_rounded,
                    child: Column(
                      children: [
                        for (final method in PaymentMethod.values) ...[
                          _PaymentTile(
                            method: method,
                            selected: state.paymentMethod == method,
                            onTap: () => context
                                .read<CheckoutBloc>()
                                .add(CheckoutPaymentMethodChanged(method)),
                          ),
                          if (method != PaymentMethod.values.last)
                            const SizedBox(height: 8),
                        ],
                        if (state.paymentMethod == PaymentMethod.card) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: Validators.cardNumber,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Card number',
                              hintText: '1234 5678 9012 3456',
                              prefixIcon: Icon(Icons.credit_card_rounded),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _cardHolderController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: Validators.cardHolder,
                            decoration: const InputDecoration(
                              labelText: 'Card holder',
                              hintText: 'Name on card',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _expiryController,
                                  keyboardType: TextInputType.datetime,
                                  textInputAction: TextInputAction.next,
                                  validator: Validators.expiry,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Expiry',
                                    hintText: 'MM/YY',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  validator: Validators.cvv,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (state.paymentMethod == PaymentMethod.paypal) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _paypalController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            decoration: const InputDecoration(
                              labelText: 'PayPal email',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                          ),
                        ],
                        if (state.paymentMethod == PaymentMethod.cash) ...[
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Please have the exact amount ready when your order arrives.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _OrderSummaryCard(summary: summary),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            Text(
                              formatCurrency(summary.total),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 190,
                        child: PrimaryButton(
                          label: 'Place order',
                          icon: Icons.lock_outline_rounded,
                          isLoading: state.isSubmitting,
                          onPressed: summary.isEmpty ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    return switch (method) {
      PaymentMethod.paypal => Icons.account_balance_wallet_outlined,
      PaymentMethod.card => Icons.credit_card_rounded,
      PaymentMethod.cash => Icons.payments_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.07)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      method.description,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.summary});

  final CheckoutSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          _Row(label: 'Items', value: '${summary.itemsCount}'),
          _Row(label: 'Subtotal', value: formatCurrency(summary.subtotal)),
          _Row(label: 'Discount', value: '-${formatCurrency(summary.discount)}'),
          _Row(label: 'Delivery', value: formatCurrency(summary.delivery)),
          const Divider(height: 20),
          _Row(
            label: 'Total',
            value: formatCurrency(summary.total),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? null : scheme.onSurfaceVariant,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 16 : 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: bold ? scheme.primary : null,
              fontWeight: FontWeight.w700,
              fontSize: bold ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
