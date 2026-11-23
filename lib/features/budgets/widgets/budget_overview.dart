import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/budget_analytics.dart';
import '../data/budget_models.dart';

/// The headline figure: total spent against total budgeted this month.
class BudgetOverview extends StatelessWidget {
  const BudgetOverview({
    super.key,
    required this.progress,
    required this.currencySymbol,
  });

  final List<BudgetProgress> progress;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final (spent, limit) = BudgetAnalytics.totals(progress);
    final over = spent > limit;
    final share = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PulseSpacing.screenGutter),
      child: PulseCard(
        tone: PulseCardTone.inverse,
        radius: PulseRadii.cardLarge,
        padding: const EdgeInsets.all(PulseSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spent this month',
              style: PulseTypography.caption.copyWith(
                color: colors.onInverse.withValues(alpha: 0.55),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: PulseSpacing.xs),
            // Stacked rather than one Row: at large amounts, "₹21,500" plus
            // "of ₹25,000" side by side overflows the card on narrow phones.
            PulseAmount(
              value: spent,
              size: PulseAmountSize.lg,
              currencySymbol: currencySymbol,
              decimalDigits: 0,
              color: over ? colors.negative : colors.onInverse,
            ),
            const SizedBox(height: PulseSpacing.xxs),
            Text(
              'of $currencySymbol${limit.toStringAsFixed(0)} budgeted',
              style: PulseTypography.bodyMd.copyWith(
                color: colors.onInverse.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: PulseSpacing.lg),
            ClipRRect(
              borderRadius: PulseRadii.chipRadius,
              child: LinearProgressIndicator(
                value: share,
                minHeight: 8,
                backgroundColor: colors.onInverse.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(
                  over ? colors.negative : colors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
