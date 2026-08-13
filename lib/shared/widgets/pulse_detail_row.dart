import 'package:flutter/material.dart';

import '../../core/theme/pulse_theme.dart';
import 'pulse_card.dart';

/// A label/value pair on its own quiet surface.
///
/// Pulse stacks these instead of using a divided list — the gap between rows
/// separates them, so no dividers are needed. Used by card details and
/// transaction details alike.
class PulseDetailRow extends StatelessWidget {
  const PulseDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? valueColor;

  /// Optional widget after the value — a chip, a copy button.
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: PulseSpacing.sm),
      child: PulseCard(
        tone: PulseCardTone.muted,
        radius: PulseRadii.input,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: PulseSpacing.lg,
          vertical: PulseSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: PulseTypography.metadata.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: PulseSpacing.lg),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: PulseTypography.titleSm.copyWith(
                  color: valueColor ?? colors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: PulseSpacing.md),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
