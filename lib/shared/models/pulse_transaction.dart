import 'package:flutter/foundation.dart';

import 'transaction_category.dart';

/// Currency Pulse displays by default.
///
/// Carried on each record rather than assumed globally, so multi-currency
/// accounts need no model change later.
const String kDefaultCurrencySymbol = '₹';

/// Where a transaction got to.
enum TransactionStatus {
  completed('Completed'),
  pending('Pending'),
  failed('Failed');

  const TransactionStatus(this.label);

  final String label;
}

/// A single movement of money.
///
/// [amount] is signed: negative is an outflow, positive an inflow. Shaped to
/// map cleanly onto a REST payload in a later phase — hence the plain fields
/// and the [fromJson] seam.
@immutable
class PulseTransaction {
  const PulseTransaction({
    required this.id,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.occurredAt,
    required this.cardId,
    this.paymentMethod = 'Pulse Card',
    this.description,
    this.status = TransactionStatus.completed,
    this.currencySymbol = kDefaultCurrencySymbol,
  });

  final String id;

  /// Merchant, payer or recipient.
  final String merchant;

  final TransactionCategory category;

  /// Signed: negative for spend, positive for income.
  final double amount;

  final DateTime occurredAt;

  /// The card this ran through — lets the Cards screen show its own activity.
  final String cardId;

  /// Human-readable method, e.g. `Pulse Virtual Debit •••• 4921`.
  final String paymentMethod;

  final String? description;

  final TransactionStatus status;

  final String currencySymbol;

  bool get isIncome => amount > 0;

  /// Round amounts read better without decimals; only show them when the
  /// value actually has a fractional part.
  int get displayDecimals => amount % 1 == 0 ? 0 : 2;

  /// Midnight on the day this happened — the grouping key for the feed.
  DateTime get day =>
      DateTime(occurredAt.year, occurredAt.month, occurredAt.day);

  /// Matches free-text search against merchant and category.
  bool matches(String query) {
    if (query.isEmpty) return true;
    final needle = query.toLowerCase().trim();
    return merchant.toLowerCase().contains(needle) ||
        category.label.toLowerCase().contains(needle);
  }

  /// A short, column-friendly time stamp.
  ///
  /// Today collapses to a clock time, yesterday to a word, anything older to
  /// a day and month — never long enough to crowd the amount beside it.
  String shortWhenLabel(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final daysAgo = today.difference(day).inDays;

    if (daysAgo == 0) return clockLabel;
    if (daysAgo == 1) return 'Yesterday';
    return '${occurredAt.day} ${monthNames[occurredAt.month - 1]}';
  }

  /// `1:12 PM`
  String get clockLabel {
    final hour24 = occurredAt.hour;
    final hour = switch (hour24) {
      0 => 12,
      > 12 => hour24 - 12,
      _ => hour24,
    };
    final minute = occurredAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${hour24 < 12 ? 'AM' : 'PM'}';
  }

  /// `12 August 2026`
  String get fullDateLabel =>
      '${occurredAt.day} ${fullMonthNames[occurredAt.month - 1]} '
      '${occurredAt.year}';

  static const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const fullMonthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  factory PulseTransaction.fromJson(Map<String, dynamic> json) {
    return PulseTransaction(
      id: json['id'] as String,
      merchant: json['merchant'] as String,
      category: TransactionCategory.values.byName(json['category'] as String),
      amount: (json['amount'] as num).toDouble(),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      cardId: json['cardId'] as String,
      paymentMethod: json['paymentMethod'] as String? ?? 'Pulse Card',
      description: json['description'] as String?,
      status: TransactionStatus.values.byName(
        json['status'] as String? ?? 'completed',
      ),
      currencySymbol:
          json['currencySymbol'] as String? ?? kDefaultCurrencySymbol,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PulseTransaction && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
