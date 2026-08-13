import 'package:flutter/material.dart';

/// The kinds of money movement Pulse understands.
///
/// The icon lives on the enum so every surface that renders a transaction
/// picks the same glyph without a lookup table scattered through the UI.
enum TransactionCategory {
  food('Food', Icons.restaurant_rounded),
  shopping('Shopping', Icons.shopping_bag_rounded),
  transport('Transport', Icons.directions_car_rounded),
  entertainment('Entertainment', Icons.play_circle_fill_rounded),
  bills('Bills', Icons.receipt_long_rounded),
  travel('Travel', Icons.flight_takeoff_rounded),
  health('Health', Icons.favorite_rounded),
  investments('Investments', Icons.account_balance_rounded),
  transfer('Transfer', Icons.swap_horiz_rounded),
  income('Income', Icons.savings_rounded);

  const TransactionCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}
