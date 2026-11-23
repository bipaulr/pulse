import 'package:flutter/material.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/budget_models.dart';

/// One category's monthly cap and how close it is to being hit.
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({
    super.key,
    required this.progress,
    required this.currencySymbol,
    required this.onTap,
  });

  final BudgetProgress progress;
  final String currencySymbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final over = progress.isOverBudget;
    final barColor = over ? colors.negative : colors.accent;

    return PulseCard(
      tone: PulseCardTone.muted,
      radius: PulseRadii.card,
      onTap: onTap,
      padding: const EdgeInsets.all(PulseSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: PulseRadii.iconRadius,
                ),
                child: Icon(
                  progress.budget.category.icon,
                  size: 18,
                  color: colors.accentMuted,
                ),
              ),
              const SizedBox(width: PulseSpacing.md),
              Expanded(
                child: Text(
                  progress.budget.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PulseTypography.labelSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (over)
                const PulseChip(
                  label: 'Over',
                  tone: PulseChipTone.outline,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: PulseSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              PulseAmount(
                value: progress.spent,
                size: PulseAmountSize.sm,
                currencySymbol: currencySymbol,
                decimalDigits: 0,
                color: over ? colors.negative : colors.textPrimary,
              ),
              Text(
                ' / $currencySymbol'
                '${progress.budget.monthlyLimit.toStringAsFixed(0)}',
                style: PulseTypography.metadata.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PulseSpacing.sm),
          ClipRRect(
            borderRadius: PulseRadii.chipRadius,
            child: LinearProgressIndicator(
              value: progress.clampedShare,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
