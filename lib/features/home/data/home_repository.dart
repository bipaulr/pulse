import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../shared/data/mock_dataset.dart';
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
/// The mock dataset's user is overlaid with whoever actually signed in, so a
/// freshly signed-up name shows up in the greeting instead of always reading
/// "Aarav" — the two are only guaranteed to match for the demo account.
final homeSnapshotProvider = Provider<HomeSnapshot>((ref) {
  final snapshot = ref.watch(homeRepositoryProvider).load();
  final signedInUser = ref.watch(authControllerProvider).user;
  if (signedInUser == null) return snapshot;
  return snapshot.copyWith(user: signedInUser);
});
