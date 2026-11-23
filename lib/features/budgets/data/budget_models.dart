import 'package:flutter/foundation.dart';

import '../../../shared/models/models.dart';

/// Categories a user can cap spending on.
///
/// Transfer and Income aren't expenses, so they're excluded from budgeting
/// entirely — capping "how much you transfer" isn't a meaningful limit.
const budgetableCategories = [
  TransactionCategory.food,
  TransactionCategory.shopping,
  TransactionCategory.transport,
  TransactionCategory.entertainment,
  TransactionCategory.bills,
  TransactionCategory.travel,
  TransactionCategory.health,
  TransactionCategory.investments,
];

/// A monthly spending cap on one category.
@immutable
class Budget {
  const Budget({required this.category, required this.monthlyLimit});

  final TransactionCategory category;
  final double monthlyLimit;
}

/// A [Budget] plus how much of it has actually been spent this month.
@immutable
class BudgetProgress {
  const BudgetProgress({required this.budget, required this.spent});

  final Budget budget;

  /// Positive magnitude spent in [budget]'s category this calendar month.
  final double spent;

  /// Fraction spent, uncapped — can exceed 1 when over budget.
  double get share =>
      budget.monthlyLimit <= 0 ? 0 : spent / budget.monthlyLimit;

  /// [share] clamped to 0..1, for a progress bar that never overshoots.
  double get clampedShare => share.clamp(0.0, 1.0);

  double get remaining => budget.monthlyLimit - spent;

  bool get isOverBudget => spent > budget.monthlyLimit;
}
