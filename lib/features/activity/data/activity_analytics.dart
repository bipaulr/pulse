import 'package:flutter/widgets.dart' show IconData;

import '../../../shared/models/models.dart';
import 'activity_models.dart';

/// Pure analytics over a transaction list.
///
/// Deliberately plain functions with no Flutter or Riverpod dependency, so the
/// arithmetic can be read and tested on its own. Everything the Activity
/// screen shows comes from one [summarize] call.
abstract final class ActivityAnalytics {
  /// Builds the whole Activity view model in a single pass over [transactions].
  static ActivitySummary summarize({
    required List<PulseTransaction> transactions,
    required ActivityPeriod period,
    required DateTime now,
    CategoryDirection direction = CategoryDirection.expense,
  }) {
    final buckets = bucketsFor(period, now);
    if (buckets.isEmpty) return ActivitySummary.empty(period);

    final windowStart = buckets.first.start;
    final windowEnd = buckets.last.end;

    final inWindow = transactions
        .where(
          (t) =>
              !t.occurredAt.isBefore(windowStart) &&
              t.occurredAt.isBefore(windowEnd),
        )
        .toList(growable: false);

    if (inWindow.isEmpty) {
      // Keep the (empty) buckets so the chart still draws its axis.
      return ActivitySummary(
        period: period,
        totalSpending: 0,
        totalIncome: 0,
        averageTransaction: 0,
        largestTransaction: null,
        transactionCount: 0,
        changePercent: 0,
        buckets: buckets,
        categories: const [],
        recentTransfers: const [],
        currencySymbol: kDefaultCurrencySymbol,
      );
    }

    var totalSpending = 0.0;
    var totalIncome = 0.0;
    var spendCount = 0;
    PulseTransaction? largest;
    final bucketTotals = List<double>.filled(buckets.length, 0);

    for (final transaction in inWindow) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
        continue;
      }

      final magnitude = transaction.amount.abs();
      totalSpending += magnitude;
      spendCount++;

      if (largest == null || magnitude > largest.amount.abs()) {
        largest = transaction;
      }

      for (var i = 0; i < buckets.length; i++) {
        if (buckets[i].contains(transaction.occurredAt)) {
          bucketTotals[i] += magnitude;
          break;
        }
      }
    }

    final filledBuckets = [
      for (var i = 0; i < buckets.length; i++)
        MonthlySpend(
          label: buckets[i].label,
          amount: bucketTotals[i],
          start: buckets[i].start,
          end: buckets[i].end,
        ),
    ];

    return ActivitySummary(
      period: period,
      totalSpending: totalSpending,
      totalIncome: totalIncome,
      averageTransaction: spendCount == 0 ? 0 : totalSpending / spendCount,
      largestTransaction: largest,
      transactionCount: spendCount,
      changePercent: percentChange(bucketTotals),
      buckets: filledBuckets,
      categories: breakdown(inWindow, direction),
      recentTransfers: inWindow.take(4).toList(growable: false),
      currencySymbol: inWindow.first.currencySymbol,
    );
  }

  /// Change between the final bucket and the one before it, as a percentage.
  ///
  /// Returns 0 when there is no previous bucket to compare against, and 100
  /// when spending appeared where there was none.
  static double percentChange(List<double> bucketTotals) {
    if (bucketTotals.length < 2) return 0;
    final current = bucketTotals[bucketTotals.length - 1];
    final previous = bucketTotals[bucketTotals.length - 2];
    if (previous == 0) return current == 0 ? 0 : 100;
    return (current - previous) / previous * 100;
  }

  /// Groups [transactions] for the Categories section, largest share first.
  ///
  /// Expenses group by category; income groups by merchant, since every income
  /// record carries the same category.
  static List<CategorySpend> breakdown(
    List<PulseTransaction> transactions,
    CategoryDirection direction,
  ) {
    final wantIncome = direction == CategoryDirection.income;
    final relevant = transactions.where((t) => t.isIncome == wantIncome);

    final totals = <String, double>{};
    final counts = <String, int>{};
    final icons = <String, IconData>{};
    final categories = <String, TransactionCategory?>{};

    for (final transaction in relevant) {
      final key = wantIncome ? transaction.merchant : transaction.category.label;
      totals[key] = (totals[key] ?? 0) + transaction.amount.abs();
      counts[key] = (counts[key] ?? 0) + 1;
      icons[key] = transaction.category.icon;
      categories[key] = wantIncome ? null : transaction.category;
    }

    final grandTotal = totals.values.fold<double>(0, (sum, v) => sum + v);
    if (grandTotal == 0) return const [];

    final result = [
      for (final entry in totals.entries)
        CategorySpend(
          label: entry.key,
          icon: icons[entry.key]!,
          amount: entry.value,
          share: entry.value / grandTotal,
          transactionCount: counts[entry.key]!,
          category: categories[entry.key],
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    return List.unmodifiable(result);
  }

  /// The chart's buckets for [period], oldest first, with zero amounts.
  static List<MonthlySpend> bucketsFor(ActivityPeriod period, DateTime now) {
    final count = period.bucketCount;
    return switch (period) {
      ActivityPeriod.week => _weekBuckets(now, count),
      ActivityPeriod.month => _monthBuckets(now, count),
      ActivityPeriod.quarter => _quarterBuckets(now, count),
      ActivityPeriod.year => _yearBuckets(now, count),
    };
  }

  static List<MonthlySpend> _weekBuckets(DateTime now, int count) {
    final today = DateTime(now.year, now.month, now.day);
    // Monday of the current week.
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    return [
      for (var offset = count - 1; offset >= 0; offset--)
        () {
          final start = thisWeek.subtract(Duration(days: 7 * offset));
          return MonthlySpend(
            label: '${start.day} ${PulseTransaction.monthNames[start.month - 1]}',
            amount: 0,
            start: start,
            end: start.add(const Duration(days: 7)),
          );
        }(),
    ];
  }

  static List<MonthlySpend> _monthBuckets(DateTime now, int count) {
    return [
      for (var offset = count - 1; offset >= 0; offset--)
        () {
          final start = DateTime(now.year, now.month - offset, 1);
          return MonthlySpend(
            label: PulseTransaction.monthNames[start.month - 1],
            amount: 0,
            start: start,
            end: DateTime(start.year, start.month + 1, 1),
          );
        }(),
    ];
  }

  static List<MonthlySpend> _quarterBuckets(DateTime now, int count) {
    final currentQuarterFirstMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    return [
      for (var offset = count - 1; offset >= 0; offset--)
        () {
          final start = DateTime(
            now.year,
            currentQuarterFirstMonth - offset * 3,
            1,
          );
          return MonthlySpend(
            label: 'Q${((start.month - 1) ~/ 3) + 1}',
            amount: 0,
            start: start,
            end: DateTime(start.year, start.month + 3, 1),
          );
        }(),
    ];
  }

  static List<MonthlySpend> _yearBuckets(DateTime now, int count) {
    return [
      for (var offset = count - 1; offset >= 0; offset--)
        () {
          final start = DateTime(now.year - offset, 1, 1);
          return MonthlySpend(
            label: '${start.year}',
            amount: 0,
            start: start,
            end: DateTime(start.year + 1, 1, 1),
          );
        }(),
    ];
  }
}
