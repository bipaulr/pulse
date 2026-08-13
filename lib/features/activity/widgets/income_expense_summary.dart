import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/activity_models.dart';

/// Two compact totals for the window, sitting under the chart.
///
/// Kept deliberately small — they are context for the chart, not headlines of
/// their own.
class IncomeExpenseSummary extends StatelessWidget {
  const IncomeExpenseSummary({super.key, required this.summary});

  final ActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.screenGutter,
      ),
      // IntrinsicHeight gives the two tiles a shared height without asking for
      // an unbounded one, which `stretch` alone would do inside a ListView.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.arrow_downward_rounded,
                label: 'Income',
                amount: summary.totalIncome,
                currencySymbol: summary.currencySymbol,
                tone: PulseCardTone.accentAlt,
              ),
            ),
            const SizedBox(width: PulseSpacing.md),
            Expanded(
              child: _SummaryTile(
                icon: Icons.arrow_upward_rounded,
                label: 'Expense',
                amount: summary.totalSpending,
                currencySymbol: summary.currencySymbol,
                tone: PulseCardTone.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.currencySymbol,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final double amount;
  final String currencySymbol;
  final PulseCardTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final foreground = PulseCard.foregroundOf(colors, tone);

    return PulseCard(
      tone: tone,
      radius: PulseRadii.button,
      padding: const EdgeInsets.symmetric(
        horizontal: PulseSpacing.md,
        vertical: PulseSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: foreground),
          ),
          const SizedBox(width: PulseSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.caption.copyWith(
                    color: foreground.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: PulseSpacing.xxs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: PulseAmount(
                    value: amount,
                    size: PulseAmountSize.md,
                    currencySymbol: currencySymbol,
                    decimalDigits: 0,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
