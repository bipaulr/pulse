import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../shared/data/ledger_controller.dart';
import '../../../shared/data/mock_dataset.dart';
import '../../../shared/models/models.dart';

/// Source of transaction records.
///
/// Async from the start even though the mock answers immediately — the screen
/// is then already written against the shape a REST call will have, so Phase 5
/// swaps the binding and changes nothing else.
abstract interface class TransactionsRepository {
  Future<List<PulseTransaction>> fetchAll();
}

class MockTransactionsRepository implements TransactionsRepository {
  MockTransactionsRepository({DateTime? now}) : _dataset = MockDataset(now: now);

  final MockDataset _dataset;

  @override
  Future<List<PulseTransaction>> fetchAll() async => _dataset.transactions;
}

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => MockTransactionsRepository(now: ref.watch(nowProvider)()),
);

/// Every transaction, newest first — the fixed mock history with whatever
/// Home's Quick Actions have added on top (see [ledgerControllerProvider]),
/// so a deposit or transfer made from Home shows up here too.
final allTransactionsProvider = FutureProvider<List<PulseTransaction>>((
  ref,
) async {
  final base = await ref.watch(transactionsRepositoryProvider).fetchAll();
  final additions = ref.watch(ledgerControllerProvider).transactions;
  return [...additions, ...base];
});

/// Lookup for the details screen. Null while loading or if the id is unknown.
final transactionByIdProvider = Provider.family<PulseTransaction?, String>((
  ref,
  id,
) {
  final all = ref.watch(allTransactionsProvider).value;
  if (all == null) return null;
  for (final transaction in all) {
    if (transaction.id == id) return transaction;
  }
  return null;
});

/// The transactions that ran through one card.
final transactionsForCardProvider =
    Provider.family<List<PulseTransaction>, String>((ref, cardId) {
      final all = ref.watch(allTransactionsProvider).value ?? const [];
      return all
          .where((transaction) => transaction.cardId == cardId)
          .toList(growable: false);
    });
