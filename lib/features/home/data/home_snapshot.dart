import 'package:flutter/foundation.dart';

import '../../../shared/models/models.dart';

/// Everything the Home screen needs, in one value.
///
/// One object rather than four providers keeps the screen's data
/// dependencies obvious, and matches the shape a single `GET /home` response
/// would take when this moves to REST.
@immutable
class HomeSnapshot {
  const HomeSnapshot({
    required this.user,
    required this.balance,
    required this.card,
    required this.recentTransactions,
  });

  final UserProfile user;
  final BalanceSummary balance;
  final PaymentCard card;
  final List<PulseTransaction> recentTransactions;

  HomeSnapshot copyWith({UserProfile? user}) => HomeSnapshot(
    user: user ?? this.user,
    balance: balance,
    card: card,
    recentTransactions: recentTransactions,
  );
}
