import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/pulse_theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import 'data/budget_models.dart';
import 'data/budgets_repository.dart';
import 'widgets/budget_edit_sheet.dart';
import 'widgets/budget_overview.dart';
import 'widgets/budget_progress_card.dart';

/// This month's spending caps: the total, each category's progress, and a
/// way to add a cap on whatever isn't budgeted yet.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.pulseColors;
    final progress = ref.watch(budgetProgressProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: PulseMotion.standard,
          child: progress.when(
            loading: () => const _BudgetsSkeleton(key: ValueKey('loading')),
            error: (error, _) => PulseErrorState(
              key: const ValueKey('error'),
              title: 'Could not load your budgets',
              onRetry: () => ref.invalidate(budgetsProvider),
            ),
            data: (list) =>
                _BudgetsBody(key: const ValueKey('data'), progress: list),
          ),
        ),
      ),
    );
  }
}

class _BudgetsBody extends ConsumerWidget {
  const _BudgetsBody({super.key, required this.progress});

  final List<BudgetProgress> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgeted = {for (final p in progress) p.budget.category};
    final unbudgeted = budgetableCategories
        .where((category) => !budgeted.contains(category))
        .toList(growable: false);
    final currencySymbol = kDefaultCurrencySymbol;

    return ListView(
      padding: const EdgeInsets.only(
        top: PulseSpacing.md,
        bottom: PulseSpacing.bottomNavClearance,
      ),
      children: [
        const PulseFadeIn(
          child: PulseSectionHeader(
            title: 'Budgets',
            subtitle: 'Your monthly spending limits',
          ),
        ),
        const SizedBox(height: PulseSpacing.xl),
        if (progress.isEmpty)
          const PulseEmptyState(
            title: 'No budgets set',
            message: 'Cap a category below to start tracking against it.',
            icon: Icons.savings_rounded,
          )
        else ...[
          PulseFadeIn(
            delay: const Duration(milliseconds: 60),
            child: BudgetOverview(
              progress: progress,
              currencySymbol: currencySymbol,
            ),
          ),
          const SizedBox(height: PulseSpacing.sectionGap),
          PulseFadeIn(
            delay: const Duration(milliseconds: 120),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PulseSpacing.screenGutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in progress) ...[
                    BudgetProgressCard(
                      progress: entry,
                      currencySymbol: currencySymbol,
                      onTap: () => _edit(
                        context,
                        ref,
                        entry.budget.category,
                        entry.budget.monthlyLimit,
                      ),
                    ),
                    if (entry != progress.last)
                      const SizedBox(height: PulseSpacing.md),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (unbudgeted.isNotEmpty) ...[
          const SizedBox(height: PulseSpacing.sectionGap),
          PulseFadeIn(
            delay: const Duration(milliseconds: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PulseSectionHeader(title: 'Add a Budget'),
                const SizedBox(height: PulseSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PulseSpacing.screenGutter,
                  ),
                  child: Wrap(
                    spacing: PulseSpacing.sm,
                    runSpacing: PulseSpacing.sm,
                    children: [
                      for (final category in unbudgeted)
                        PulseChip(
                          label: category.label,
                          icon: category.icon,
                          onTap: () => _edit(context, ref, category, 0),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    TransactionCategory category,
    double currentLimit,
  ) async {
    final result = await showModalBottomSheet<BudgetEditResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          BudgetEditSheet(category: category, currentLimit: currentLimit),
    );
    if (result == null || !context.mounted) return;

    ref
        .read(budgetOverridesProvider.notifier)
        .setLimit(category, result.monthlyLimit);

    final message = result.monthlyLimit > 0
        ? '${category.label} budget set to '
              '$kDefaultCurrencySymbol${result.monthlyLimit.toStringAsFixed(0)}'
        : '${category.label} budget removed';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }
}

class _BudgetsSkeleton extends StatelessWidget {
  const _BudgetsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        PulseSpacing.xl,
        PulseSpacing.screenGutter,
        PulseSpacing.bottomNavClearance,
      ),
      children: const [
        PulseSkeleton.text(width: 110, height: 20),
        SizedBox(height: PulseSpacing.xl),
        PulseSkeleton.card(height: 140),
        SizedBox(height: PulseSpacing.sectionGap),
        PulseSkeleton(height: 92, radius: PulseRadii.card),
        SizedBox(height: PulseSpacing.md),
        PulseSkeleton(height: 92, radius: PulseRadii.card),
        SizedBox(height: PulseSpacing.md),
        PulseSkeleton(height: 92, radius: PulseRadii.card),
      ],
    );
  }
}
