import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/pulse_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../data/transaction_query.dart';
import '../data/transactions_repository.dart';

/// The grouped, filtered feed, with its loading, empty and error branches.
class TransactionFeedView extends ConsumerWidget {
  const TransactionFeedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(transactionFeedProvider);

    return feed.when(
      loading: () => const _FeedSkeleton(),
      error: (error, _) => PulseErrorState(
        title: 'Could not load transactions',
        onRetry: () => ref.invalidate(allTransactionsProvider),
      ),
      data: (items) {
        if (items.isEmpty) return const _FeedEmpty();
        return _FeedList(items: items);
      },
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({required this.items});

  final List<TransactionFeedItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Flattened groups keep this lazy: only visible rows are built.
      itemCount: items.length,
      padding: const EdgeInsets.only(
        bottom: PulseSpacing.bottomNavClearance,
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) {
        final item = items[index];
        return switch (item) {
          TransactionDayHeader() => _DayHeader(
            label: item.label,
            isFirst: index == 0,
          ),
          TransactionEntry() => _EntryRow(transaction: item.transaction),
        };
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.isFirst});

  final String label;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final colors = context.pulseColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        isFirst ? PulseSpacing.md : PulseSpacing.xxl,
        PulseSpacing.screenGutter,
        PulseSpacing.md,
      ),
      child: Text(
        label,
        style: PulseTypography.caption.copyWith(
          color: colors.textTertiary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.transaction});

  final PulseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        0,
        PulseSpacing.screenGutter,
        PulseSpacing.sm + 2,
      ),
      child: PulseCard(
        padding: EdgeInsets.zero,
        radius: PulseRadii.button,
        child: PulseTransactionTile(
          title: transaction.merchant,
          subtitle: transaction.category.label,
          icon: transaction.category.icon,
          amount: transaction.amount,
          currencySymbol: transaction.currencySymbol,
          decimalDigits: transaction.displayDecimals,
          trailingCaption: transaction.clockLabel,
          iconTone: transaction.isIncome
              ? PulseTransactionIconTone.accent
              : PulseTransactionIconTone.accentSoft,
          onTap: () =>
              context.push(AppRoutes.transactionDetails(transaction.id)),
        ),
      ),
    );
  }
}

/// Placeholder rows while the feed loads.
class _FeedSkeleton extends StatelessWidget {
  const _FeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PulseSpacing.screenGutter,
        PulseSpacing.lg,
        PulseSpacing.screenGutter,
        PulseSpacing.bottomNavClearance,
      ),
      children: const [
        PulseSkeleton.text(width: 70),
        SizedBox(height: PulseSpacing.lg),
        _SkeletonRow(),
        _SkeletonRow(),
        _SkeletonRow(),
        SizedBox(height: PulseSpacing.lg),
        PulseSkeleton.text(width: 96),
        SizedBox(height: PulseSpacing.lg),
        _SkeletonRow(),
        _SkeletonRow(),
      ],
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: PulseSpacing.md),
      child: Row(
        children: [
          PulseSkeleton.circle(),
          SizedBox(width: PulseSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PulseSkeleton.text(width: 120),
                SizedBox(height: PulseSpacing.sm),
                PulseSkeleton.text(width: 72, height: 11),
              ],
            ),
          ),
          PulseSkeleton.text(width: 60),
        ],
      ),
    );
  }
}

/// Distinguishes "you have no transactions" from "your search found nothing",
/// because the way out of each is different.
class _FeedEmpty extends ConsumerWidget {
  const _FeedEmpty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(transactionQueryProvider);

    if (!query.isFiltering) {
      return const SingleChildScrollView(
        child: PulseEmptyState(
          title: 'No transactions yet',
          message: 'Once money moves, everything shows up here.',
          icon: Icons.receipt_long_rounded,
        ),
      );
    }

    return SingleChildScrollView(
      child: PulseEmptyState(
        title: 'No matching transactions',
        message: query.search.isEmpty
            ? 'Nothing in this category yet. Try another filter.'
            : 'Nothing matched "${query.search}". Try a different search.',
        icon: Icons.search_off_rounded,
        actionLabel: 'Clear filters',
        onAction: () => ref.read(transactionQueryProvider.notifier).clear(),
      ),
    );
  }
}
