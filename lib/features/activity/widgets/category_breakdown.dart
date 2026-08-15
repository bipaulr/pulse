import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/activity_models.dart';
import '../data/activity_providers.dart';

/// Where the money went, as a horizontally scrolling row of cards.
///
/// Horizontal rather than a stacked table: the count varies with the period,
/// and scrolling keeps the section a fixed height however many there are.
class CategoryBreakdown extends ConsumerWidget {
  const CategoryBreakdown({super.key, required this.summary});

  final ActivitySummary summary;

  static const _cardWidth = 150.0;
  static const _rowHeight = 158.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(categoryDirectionProvider);
    final categories = summary.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PulseSectionHeader(
          title: 'Categories',
          trailing: PulseChip.dropdown(
            label: direction.label,
            dense: true,
            onTap: () => _toggle(ref, direction),
          ),
        ),
        const SizedBox(height: PulseSpacing.md),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PulseSpacing.screenGutter,
            ),
            child: PulseCard(
              padding: EdgeInsets.zero,
              child: PulseEmptyState(
                title: 'No ${direction.label.toLowerCase()} yet',
                message: 'Nothing recorded for this period.',
                icon: Icons.donut_small_rounded,
                compact: true,
              ),
            ),
          )
        else
          SizedBox(
            height: _rowHeight,
            child: PulseHorizontalFade(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: PulseSpacing.screenGutter,
                ),
                itemCount: categories.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: PulseSpacing.md),
                itemBuilder: (context, index) => _CategoryCard(
                  spend: categories[index],
                  currencySymbol: summary.currencySymbol,
                  width: _cardWidth,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _toggle(WidgetRef ref, CategoryDirection current) {
    ref
        .read(categoryDirectionProvider.notifier)
        .select(
          current == CategoryDirection.expense
              ? CategoryDirection.income
              : CategoryDirection.expense,
        );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.spend,
    required this.currencySymbol,
    required this.width,
  });

  final CategorySpend spend;
  final String currencySymbol;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return PulseCard(
      tone: PulseCardTone.muted,
      radius: PulseRadii.card,
      width: width,
      padding: const EdgeInsets.all(PulseSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: PulseRadii.iconRadius,
            ),
            child: Icon(spend.icon, size: 20, color: colors.accentMuted),
          ),
          const SizedBox(height: PulseSpacing.md),
          Text(
            spend.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PulseTypography.metadata.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: PulseSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: PulseAmount(
              value: spend.amount,
              size: PulseAmountSize.md,
              currencySymbol: currencySymbol,
              decimalDigits: 0,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: PulseSpacing.md),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: PulseRadii.chipRadius,
                  child: LinearProgressIndicator(
                    value: spend.share.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: colors.border,
                    valueColor: AlwaysStoppedAnimation(colors.accent),
                  ),
                ),
              ),
              const SizedBox(width: PulseSpacing.sm),
              Text(
                spend.sharePercentLabel,
                style: PulseTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
