import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../shared/data/ledger_controller.dart';
import '../../../shared/data/mock_dataset.dart';
import '../../../shared/models/models.dart';
import '../../auth/data/auth_controller.dart';
import 'home_snapshot.dart';

/// Source of the Home screen's data.
///
/// The seam that a REST-backed implementation will slot into: swap the
/// binding in [homeRepositoryProvider] and nothing in the UI changes.
abstract interface class HomeRepository {
  HomeSnapshot load();
}

/// Reads the shared sample data, so Home can never disagree with Cards or
/// Transactions about the same record.
class MockHomeRepository implements HomeRepository {
  MockHomeRepository({DateTime? now}) : _dataset = MockDataset(now: now);

  final MockDataset _dataset;

  @override
  HomeSnapshot load() => HomeSnapshot(
    user: MockDataset.user,
    balance: MockDataset.balance,
    card: MockDataset.cards.first,
    recentTransactions: _dataset.recentTransactions,
  );
}

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => MockHomeRepository(now: ref.watch(nowProvider)()),
);

/// The Home screen's data.
///
/// Synchronous today because the source is local. When this becomes a network
/// call it turns into a `FutureProvider` and the screen switches to
/// `AsyncValue.when` — `PulseSkeleton` and `PulseErrorState` already exist for
/// the other two branches.
///
/// The mock dataset's user and card holder name are overlaid with whoever
/// actually signed in, so a freshly signed-up identity shows up consistently
/// in the greeting *and* on the card face — the two are only guaranteed to
/// match the underlying mock data for the demo account. Merchant data is
/// never touched by this: that's fixed demo financial data, not identity.
///
/// The balance and recent-activity list, on the other hand, are overlaid with
/// [ledgerControllerProvider] — Home's Quick Actions write there, and this is
/// what makes a deposit or transfer show up immediately.
final homeSnapshotProvider = Provider<HomeSnapshot>((ref) {
  final snapshot = ref.watch(homeRepositoryProvider).load();
  final additions = ref.watch(ledgerControllerProvider);
  final signedInUser = ref.watch(authControllerProvider).user;

  final withLedger = snapshot.copyWith(
    balance: BalanceSummary(
      total: snapshot.balance.total + additions.balanceDelta,
      changePercent: snapshot.balance.changePercent,
      periodLabel: snapshot.balance.periodLabel,
      currencySymbol: snapshot.balance.currencySymbol,
    ),
    recentTransactions: [
      ...additions.transactions,
      ...snapshot.recentTransactions,
    ].take(5).toList(growable: false),
  );

  if (signedInUser == null) return withLedger;
  return withLedger.copyWith(
    user: signedInUser,
    card: withLedger.card.copyWith(holderName: signedInUser.fullName),
  );
});
