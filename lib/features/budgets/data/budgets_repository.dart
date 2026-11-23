import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../shared/models/models.dart';
import '../../transactions/data/transactions_repository.dart';
import 'budget_analytics.dart';
import 'budget_models.dart';

/// Source of the user's budgets.
///
/// The seam a REST-backed implementation slots into later, matching every
/// other repository in the app.
abstract interface class BudgetsRepository {
  Future<List<Budget>> fetchBudgets();
}

class MockBudgetsRepository implements BudgetsRepository {
  const MockBudgetsRepository();

  @override
  Future<List<Budget>> fetchBudgets() async => const [
    Budget(category: TransactionCategory.food, monthlyLimit: 8000),
    Budget(category: TransactionCategory.shopping, monthlyLimit: 6000),
    Budget(category: TransactionCategory.transport, monthlyLimit: 2500),
    Budget(category: TransactionCategory.entertainment, monthlyLimit: 2000),
    Budget(category: TransactionCategory.bills, monthlyLimit: 5000),
  ];
}

final budgetsRepositoryProvider = Provider<BudgetsRepository>(
  (ref) => const MockBudgetsRepository(),
);

/// Session edits layered onto the mock seed — the same pattern the ledger's
/// deposits/withdrawals and card replacement use, so swapping in a real
/// backend later only changes [budgetsRepositoryProvider]'s binding.
///
/// A limit of 0 is how a budget is removed: [budgetsProvider] filters it out.
class BudgetOverrides extends Notifier<Map<TransactionCategory, double>> {
  @override
  Map<TransactionCategory, double> build() => const {};

  void setLimit(TransactionCategory category, double monthlyLimit) {
    state = {...state, category: monthlyLimit};
  }
}

final budgetOverridesProvider =
    NotifierProvider<BudgetOverrides, Map<TransactionCategory, double>>(
      BudgetOverrides.new,
    );

/// Every budgeted category with a limit above zero, alphabetical by label.
final budgetsProvider = FutureProvider<List<Budget>>((ref) async {
  final base = await ref.watch(budgetsRepositoryProvider).fetchBudgets();
  final overrides = ref.watch(budgetOverridesProvider);

  final merged = {
    for (final budget in base) budget.category: budget.monthlyLimit,
    ...overrides,
  };

  return [
    for (final entry in merged.entries)
      if (entry.value > 0)
        Budget(category: entry.key, monthlyLimit: entry.value),
  ]..sort((a, b) => a.category.label.compareTo(b.category.label));
});

/// This month's spend against every budgeted category.
final budgetProgressProvider = Provider<AsyncValue<List<BudgetProgress>>>((
  ref,
) {
  final now = ref.watch(nowProvider)();
  final budgets = ref.watch(budgetsProvider);
  final transactions = ref.watch(allTransactionsProvider);

  return budgets.when(
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    data: (budgetList) => transactions.whenData(
      (txns) => BudgetAnalytics.progressFor(
        budgets: budgetList,
        transactions: txns,
        now: now,
      ),
    ),
  );
});
