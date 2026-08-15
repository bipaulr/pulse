import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/pulse_theme.dart';
import '../../shared/widgets/widgets.dart';
import '../transactions/data/transactions_repository.dart';
import 'data/activity_models.dart';
import 'data/activity_providers.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/income_expense_summary.dart';
import 'widgets/recent_transfers.dart';
import 'widgets/spending_overview.dart';

/// Spending analytics: the visual centrepiece of Pulse.
///
/// Hierarchy, top to bottom: total spending → period selector → chart →
/// income/expense → categories → recent transfers.
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.pulseColors;
    final summary = ref.watch(activitySummaryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      // The width constraint lives in AppShell now, so every screen shares it.
      body: SafeArea(
        bottom: false,
        // Keyed only by which branch is showing, not by the summary's own
        // content — a period change still produces a new AsyncData, but that
        // already flows through PulseSpendingChart's own tween. Keying this
        // by period too would layer a whole-screen cross-fade on top of that
        // and fight it instead of complementing it.
        child: AnimatedSwitcher(
          duration: PulseMotion.standard,
          child: summary.when(
            loading: () => const _ActivitySkeleton(key: ValueKey('loading')),
            error: (error, _) => PulseErrorState(
              key: const ValueKey('error'),
              title: 'Could not load your activity',
              onRetry: () => ref.invalidate(allTransactionsProvider),
            ),
            data: (data) =>
                _ActivityBody(key: const ValueKey('data'), summary: data),
          ),
        ),
      ),
    );
  }
}

class _ActivityBody extends StatelessWidget {
  const _ActivityBody({super.key, required this.summary});

  final ActivitySummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: PulseSpacing.md,
        bottom: PulseSpacing.bottomNavClearance,
      ),
      children: [
        const PulseFadeIn(child: _ActivityHeader()),
        const SizedBox(height: PulseSpacing.xl),
        if (summary.isEmpty)
          const PulseEmptyState(
            title: 'Nothing to analyse yet',
            message: 'Spend or get paid and your activity will show up here.',
            icon: Icons.insights_rounded,
          )
        else ...[
          PulseFadeIn(
            delay: const Duration(milliseconds: 60),
            child: SpendingOverview(summary: summary),
          ),
          const SizedBox(height: PulseSpacing.lg),
          PulseFadeIn(
            delay: const Duration(milliseconds: 120),
            child: IncomeExpenseSummary(summary: summary),
          ),
          const SizedBox(height: PulseSpacing.sectionGap),
          PulseFadeIn(
            delay: const Duration(milliseconds: 180),
            child: CategoryBreakdown(summary: summary),
          ),
          const SizedBox(height: PulseSpacing.sectionGap),
          PulseFadeIn(
            delay: const Duration(milliseconds: 240),
            child: RecentTransfers(transactions: summary.recentTransfers),
          ),
        ],
      ],
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader();

  @override
  Widget build(BuildContext context) {
    return PulseSectionHeader(
      title: 'Activity',
      subtitle: 'How your money moved',
      trailing: PulseIconButton(
        icon: Icons.more_horiz_rounded,
        tone: PulseIconButtonTone.surface,
        tooltip: 'Activity options',
        onPressed: () => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Exporting activity is coming soon'),
              duration: Duration(seconds: 2),
            ),
          ),
      ),
    );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton({super.key});

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
        PulseSkeleton.text(width: 120, height: 20),
        SizedBox(height: PulseSpacing.xxl),
        Center(child: PulseSkeleton.text(width: 180, height: 40)),
        SizedBox(height: PulseSpacing.xl),
        PulseSkeleton.card(height: 240),
        SizedBox(height: PulseSpacing.lg),
        Row(
          children: [
            Expanded(child: PulseSkeleton(height: 62, radius: 20)),
            SizedBox(width: PulseSpacing.md),
            Expanded(child: PulseSkeleton(height: 62, radius: 20)),
          ],
        ),
        SizedBox(height: PulseSpacing.sectionGap),
        PulseSkeleton.text(width: 110),
        SizedBox(height: PulseSpacing.lg),
        PulseSkeleton.card(height: 150),
      ],
    );
  }
}
