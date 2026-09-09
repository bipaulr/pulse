import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../models/models.dart';
import 'mock_dataset.dart';

/// What Home's Quick Actions have added on top of the fixed mock seed.
///
/// [MockDataset] stays the immutable sample data; this is the layer Deposit,
/// Withdraw and Transfer actually write to. [homeSnapshotProvider] and
/// [allTransactionsProvider] both read it, so a deposit shows up in Recent
/// Activity and in the full Transactions feed from the same write.
@immutable
class LedgerAdditions {
  const LedgerAdditions({this.balanceDelta = 0, this.transactions = const []});

  final double balanceDelta;

  /// Newest first.
  final List<PulseTransaction> transactions;
}

class LedgerController extends Notifier<LedgerAdditions> {
  @override
  LedgerAdditions build() => const LedgerAdditions();

  void deposit(double amount, {String merchant = 'Deposit'}) =>
      _record(amount: amount, merchant: merchant, category: TransactionCategory.income);

  void withdraw(double amount, {String merchant = 'Withdrawal'}) => _record(
    amount: -amount,
    merchant: merchant,
    category: TransactionCategory.transfer,
  );

  void transfer(double amount, {required String recipient}) => _record(
    amount: -amount,
    merchant: recipient,
    category: TransactionCategory.transfer,
  );

  void _record({
    required double amount,
    required String merchant,
    required TransactionCategory category,
  }) {
    final primaryCard = MockDataset.cardById(MockDataset.primaryCardId);
    final transaction = PulseTransaction(
      id: 'txn_local_${DateTime.now().microsecondsSinceEpoch}',
      merchant: merchant,
      category: category,
      amount: amount,
      occurredAt: ref.read(nowProvider)(),
      cardId: primaryCard.id,
      paymentMethod: primaryCard.paymentMethodLabel,
    );

    state = LedgerAdditions(
      balanceDelta: state.balanceDelta + amount,
      transactions: [transaction, ...state.transactions],
    );
  }
}

final ledgerControllerProvider =
    NotifierProvider<LedgerController, LedgerAdditions>(LedgerController.new);
