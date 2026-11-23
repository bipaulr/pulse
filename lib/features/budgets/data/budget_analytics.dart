import '../../../shared/models/models.dart';
import 'budget_models.dart';

/// Pure analytics over a transaction list, scoped to budgets.
///
/// Kept separate from [ActivityAnalytics] even though both group by
/// category: Activity reports over a selectable multi-bucket window, while a
/// budget is always "this calendar month," so the two never share a
/// windowing rule.
abstract final class BudgetAnalytics {
  /// How much of each [budgets] entry has been spent so far this calendar
  /// month, largest spend first.
  static List<BudgetProgress> progressFor({
    required List<Budget> budgets,
    required List<PulseTransaction> transactions,
    required DateTime now,
  }) {
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    final spentByCategory = <TransactionCategory, double>{};
    for (final transaction in transactions) {
      if (transaction.isIncome) continue;
      if (transaction.occurredAt.isBefore(monthStart) ||
          !transaction.occurredAt.isBefore(monthEnd)) {
        continue;
      }
      spentByCategory[transaction.category] =
          (spentByCategory[transaction.category] ?? 0) +
          transaction.amount.abs();
    }

    return [
      for (final budget in budgets)
        BudgetProgress(
          budget: budget,
          spent: spentByCategory[budget.category] ?? 0,
        ),
    ]..sort((a, b) => b.spent.compareTo(a.spent));
  }

  /// Combined spent and combined limit across every budgeted category.
  static (double spent, double limit) totals(List<BudgetProgress> progress) {
    var spent = 0.0;
    var limit = 0.0;
    for (final entry in progress) {
      spent += entry.spent;
      limit += entry.budget.monthlyLimit;
    }
    return (spent, limit);
  }
}
