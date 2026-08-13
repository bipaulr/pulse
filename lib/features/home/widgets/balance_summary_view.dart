import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// The screen's headline figure.
///
/// Sits directly on the canvas rather than in a card so nothing competes with
/// it, and the trend reads as a quiet footnote beneath.
class BalanceSummaryView extends StatelessWidget {
  const BalanceSummaryView({super.key, required this.balance});

  final BalanceSummary balance;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.screenGutter,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Balance',
            style: PulseTypography.metadata.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: PulseSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: PulseAmount(
              value: balance.total,
              size: PulseAmountSize.xl,
              currencySymbol: balance.currencySymbol,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: PulseSpacing.md),
          PulseChip(
            label: balance.changeLabel,
            icon: balance.isUp
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            tone: PulseChipTone.accentSoft,
            dense: true,
          ),
        ],
      ),
    );
  }
}
