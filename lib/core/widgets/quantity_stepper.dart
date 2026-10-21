import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.compact = false,
    this.min = 1,
    this.max = AppConstants.maxCartQuantity,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool compact;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 30.0 : 38.0;
    final iconSize = compact ? 16.0 : 20.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            size: size,
            iconSize: iconSize,
            enabled: quantity > min,
            onPressed: onDecrease,
          ),
          SizedBox(
            width: compact ? 32 : 42,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: compact ? 13 : 15,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            size: size,
            iconSize: iconSize,
            enabled: quantity < max,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        iconSize: iconSize,
        style: IconButton.styleFrom(
          backgroundColor:
              enabled ? scheme.primary : scheme.surfaceContainerHighest,
          foregroundColor:
              enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
        ),
        icon: Icon(icon),
      ),
    );
  }
}
