import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pulse_theme.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/activity_models.dart';
import '../data/activity_providers.dart';

/// Total spending, the period selector, and the chart panel.
///
/// The headline figure and the chart share one selection: tapping a bar
/// retargets the number above it, so the two never disagree.
class SpendingOverview extends ConsumerWidget {
  const SpendingOverview({super.key, required this.summary});

  final ActivitySummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.pulseColors;
    final selectedIndex = ref.watch(resolvedBucketIndexProvider);
    final buckets = summary.buckets;
    final selected = selectedIndex < buckets.length
        ? buckets[selectedIndex]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.screenGutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total Spending',
                style: PulseTypography.metadata.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: PulseSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: PulseAmount(
                  // The window total, so this never contradicts the Expense
                  // tile below. Per-bar figures live inside the chart panel.
                  value: summary.totalSpending,
                  size: PulseAmountSize.xl,
                  currencySymbol: summary.currencySymbol,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: PulseSpacing.md),
              PulseChip(
                label: summary.changeLabel,
                icon: summary.isUp
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                tone: PulseChipTone.accentSoft,
                dense: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: PulseSpacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PulseSpacing.screenGutter,
          ),
          child: PulseCard(
            tone: PulseCardTone.inverse,
            radius: PulseRadii.cardLarge,
            padding: const EdgeInsets.all(PulseSpacing.lg),
            notchSize: const Size(122, 54),
            notchAction: const _PeriodSelector(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sits left of the notch, so the carved corner costs no space
                // and the tallest bar can never reach up into it.
                _SelectionReadout(
                  bucket: selected,
                  currencySymbol: summary.currencySymbol,
                ),
                const SizedBox(height: PulseSpacing.lg),
                PulseSpendingChart(
                  bars: [
                    for (final bucket in buckets)
                      PulseChartBar(label: bucket.label, value: bucket.amount),
                  ],
                  selectedIndex: selectedIndex,
                  currencySymbol: summary.currencySymbol,
                  onBarSelected: (index) => ref
                      .read(selectedBucketIndexProvider.notifier)
                      .select(index),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// What the highlighted bar is worth.
///
/// This is where tapping a bar shows its result; the headline above the card
/// stays the window total so the two never contradict each other.
class _SelectionReadout extends StatelessWidget {
  const _SelectionReadout({
    required this.bucket,
    required this.currencySymbol,
  });

  final MonthlySpend? bucket;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;
    final subdued = colors.onInverse.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          bucket == null ? 'Spending' : 'Spending · ${bucket!.label}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PulseTypography.caption.copyWith(
            color: subdued,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: PulseSpacing.xxs),
        // Switches value in place as the selection moves along the chart.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: PulseAmount(
            key: ValueKey(bucket?.label),
            value: bucket?.amount ?? 0,
            size: PulseAmountSize.md,
            currencySymbol: currencySymbol,
            decimalDigits: 0,
            color: colors.accentAlt,
          ),
        ),
      ],
    );
  }
}

/// `Month ▾` — a Pulse chip that opens a small sheet, never a DropdownButton.
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(activityPeriodProvider);

    return PulseChip.dropdown(
      label: period.label,
      tone: PulseChipTone.accent,
      onTap: () => _pick(context, ref, period),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    ActivityPeriod current,
  ) async {
    final chosen = await showModalBottomSheet<ActivityPeriod>(
      context: context,
      // Without this the sheet is capped at half the viewport, which its four
      // options overflow on a short window.
      isScrollControlled: true,
      builder: (sheetContext) => _PeriodSheet(current: current),
    );
    if (chosen != null) {
      ref.read(activityPeriodProvider.notifier).select(chosen);
    }
  }
}

class _PeriodSheet extends StatelessWidget {
  const _PeriodSheet({required this.current});

  final ActivityPeriod current;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return SafeArea(
      // Scrolls rather than overflows if the window is too short for the list.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          PulseSpacing.screenGutter,
          PulseSpacing.xl,
          PulseSpacing.screenGutter,
          PulseSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 44,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: PulseRadii.chipRadius,
                ),
              ),
            ),
            const SizedBox(height: PulseSpacing.xl),
            Text(
              'Show spending by',
              style: PulseTypography.headingMd.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: PulseSpacing.lg),
            for (final period in ActivityPeriod.values)
              PulseDetailRow(
                label: period.label,
                value: '${period.bucketCount} bars',
                onTap: () => Navigator.of(context).pop(period),
                trailing: Icon(
                  period == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: period == current
                      ? colors.accentMuted
                      : colors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
