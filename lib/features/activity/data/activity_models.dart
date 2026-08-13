import 'package:flutter/material.dart';

import '../../../shared/models/models.dart';

/// The window the Activity screen reports on.
///
/// Each period also fixes how the chart buckets its bars, which is what makes
/// switching period produce a genuinely different chart rather than the same
/// bars rescaled.
enum ActivityPeriod {
  week('Week', 8),
  month('Month', 6),
  quarter('Quarter', 4),
  year('Year', 3);

  const ActivityPeriod(this.label, this.bucketCount);

  final String label;

  /// How many buckets the chart plots for this period.
  final int bucketCount;
}

/// Which side of the ledger the Categories section is showing.
enum CategoryDirection {
  expense('Expense'),
  income('Income');

  const CategoryDirection(this.label);

  final String label;
}

/// One bar on the spending chart.
@immutable
class MonthlySpend {
  const MonthlySpend({
    required this.label,
    required this.amount,
    required this.start,
    required this.end,
  });

  /// Short axis label — `Aug`, `Q3`, `2026`, or a week's start date.
  final String label;

  /// Total outflow inside this bucket, as a positive number.
  final double amount;

  /// Inclusive start of the bucket.
  final DateTime start;

  /// Exclusive end of the bucket.
  final DateTime end;

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);
}

/// One card in the category breakdown.
///
/// Carries its own label and icon rather than only a [TransactionCategory],
/// because the Income view groups by source (Salary, Bonus, …) — every income
/// record shares a single category, so grouping income by category would
/// collapse to one meaningless card.
@immutable
class CategorySpend {
  const CategorySpend({
    required this.label,
    required this.icon,
    required this.amount,
    required this.share,
    required this.transactionCount,
    this.category,
  });

  final String label;
  final IconData icon;

  /// Positive magnitude.
  final double amount;

  /// Fraction of the period's total, 0..1.
  final double share;

  final int transactionCount;

  /// Set when grouped by category; null when grouped by income source.
  final TransactionCategory? category;

  /// `32%`
  String get sharePercentLabel => '${(share * 100).round()}%';
}

/// Everything the Activity screen renders, computed in one pass.
@immutable
class ActivitySummary {
  const ActivitySummary({
    required this.period,
    required this.totalSpending,
    required this.totalIncome,
    required this.averageTransaction,
    required this.largestTransaction,
    required this.transactionCount,
    required this.changePercent,
    required this.buckets,
    required this.categories,
    required this.recentTransfers,
    required this.currencySymbol,
  });

  const ActivitySummary.empty(this.period)
    : totalSpending = 0,
      totalIncome = 0,
      averageTransaction = 0,
      largestTransaction = null,
      transactionCount = 0,
      changePercent = 0,
      buckets = const [],
      categories = const [],
      recentTransfers = const [],
      currencySymbol = kDefaultCurrencySymbol;

  final ActivityPeriod period;

  /// Total outflow across the window, as a positive number.
  final double totalSpending;

  /// Total inflow across the window.
  final double totalIncome;

  /// Mean outflow per spending transaction.
  final double averageTransaction;

  /// The single biggest outflow, if there was one.
  final PulseTransaction? largestTransaction;

  /// Number of spending transactions in the window.
  final int transactionCount;

  /// Change in spending between the last bucket and the one before it.
  final double changePercent;

  /// Chart data, oldest bucket first.
  final List<MonthlySpend> buckets;

  /// Breakdown for the active [CategoryDirection], largest first.
  final List<CategorySpend> categories;

  /// A few recent movements to show under the breakdown.
  final List<PulseTransaction> recentTransfers;

  final String currencySymbol;

  bool get isEmpty => transactionCount == 0 && totalIncome == 0;

  bool get isUp => changePercent >= 0;

  /// `+12.4% this month`
  String get changeLabel {
    final sign = isUp ? '+' : '−';
    final magnitude = changePercent.abs().toStringAsFixed(1);
    return '$sign$magnitude% this ${period.label.toLowerCase()}';
  }
}
