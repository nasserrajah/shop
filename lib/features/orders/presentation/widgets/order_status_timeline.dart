import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_status.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final steps = _steps();

    return Column(
      children: [
        for (var index = 0; index < steps.length; index++)
          _TimelineStep(
            step: steps[index],
            isLast: index == steps.length - 1,
          ),
      ],
    );
  }

  List<_Step> _steps() {
    if (status == OrderStatus.cancelled) {
      return const [
        _Step(
          title: 'Order placed',
          subtitle: 'Your order was received.',
          state: _StepState.complete,
        ),
        _Step(
          title: 'Order cancelled',
          subtitle: 'This order was cancelled. No payment was captured.',
          state: _StepState.error,
        ),
      ];
    }

    if (status == OrderStatus.completed) {
      return const [
        _Step(
          title: 'Order placed',
          subtitle: 'Your order was received.',
          state: _StepState.complete,
        ),
        _Step(
          title: 'Processing',
          subtitle: 'Your items were packed.',
          state: _StepState.complete,
        ),
        _Step(
          title: 'Shipped',
          subtitle: 'Your parcel was handed to the courier.',
          state: _StepState.complete,
        ),
        _Step(
          title: 'Delivered',
          subtitle: 'Enjoy your purchase!',
          state: _StepState.complete,
        ),
      ];
    }

    return const [
      _Step(
        title: 'Order placed',
        subtitle: 'Your order was received.',
        state: _StepState.complete,
      ),
      _Step(
        title: 'Processing',
        subtitle: 'We are preparing your items.',
        state: _StepState.current,
      ),
      _Step(
        title: 'Shipped',
        subtitle: 'The courier will pick up your parcel soon.',
        state: _StepState.pending,
      ),
      _Step(
        title: 'Delivered',
        subtitle: 'Your order will arrive in 2 - 4 business days.',
        state: _StepState.pending,
      ),
    ];
  }
}

enum _StepState { complete, current, pending, error }

class _Step {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final _StepState state;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.step, required this.isLast});

  final _Step step;
  final bool isLast;

  Color _color() {
    return switch (step.state) {
      _StepState.complete => AppColors.success,
      _StepState.current => AppColors.primary,
      _StepState.pending => AppColors.textSecondary,
      _StepState.error => AppColors.danger,
    };
  }

  IconData _icon() {
    return switch (step.state) {
      _StepState.complete => Icons.check_rounded,
      _StepState.current => Icons.local_shipping_rounded,
      _StepState.pending => Icons.circle_outlined,
      _StepState.error => Icons.close_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.4),
              ),
              child: Icon(_icon(), size: 17, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: color.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: step.state == _StepState.pending
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
