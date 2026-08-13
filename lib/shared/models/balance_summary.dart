import 'package:flutter/foundation.dart';

import 'pulse_transaction.dart' show kDefaultCurrencySymbol;

/// The headline number on the Home screen, plus how it is trending.
@immutable
class BalanceSummary {
  const BalanceSummary({
    required this.total,
    required this.changePercent,
    this.periodLabel = 'this month',
    this.currencySymbol = kDefaultCurrencySymbol,
  });

  final double total;

  /// Signed percentage change over [periodLabel].
  final double changePercent;

  final String periodLabel;
  final String currencySymbol;

  bool get isUp => changePercent >= 0;

  /// `+12.4% this month`
  String get changeLabel {
    final sign = isUp ? '+' : '−';
    return '$sign${changePercent.abs().toStringAsFixed(1)}% $periodLabel';
  }

  factory BalanceSummary.fromJson(Map<String, dynamic> json) {
    return BalanceSummary(
      total: (json['total'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      periodLabel: json['periodLabel'] as String? ?? 'this month',
      currencySymbol:
          json['currencySymbol'] as String? ?? kDefaultCurrencySymbol,
    );
  }
}
