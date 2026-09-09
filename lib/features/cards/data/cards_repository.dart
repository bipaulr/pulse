import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/persistence/app_preferences.dart';
import '../../../shared/data/mock_dataset.dart';
import '../../../shared/models/models.dart';
import '../../auth/data/auth_controller.dart';

/// Source of the user's cards.
///
/// [revealPin] is a method rather than a field on [PaymentCard] on purpose: a
/// PIN is fetched on demand and never held in the model, which is how a real
/// issuer integration has to work. [replaceCard] returns the reissued card —
/// same id, new number and expiry — rather than mutating anything in place,
/// matching how a real issuer API would respond.
abstract interface class CardsRepository {
  Future<List<PaymentCard>> fetchCards();

  Future<String> revealPin(String cardId);

  Future<PaymentCard> replaceCard(String cardId);
}

class MockCardsRepository implements CardsRepository {
  const MockCardsRepository({DateTime? now}) : _now = now;

  final DateTime? _now;

  /// Fictional demo PINs. Never derived from the card number.
  static const _pins = <String, String>{
    MockDataset.primaryCardId: '4821',
    MockDataset.platinumCardId: '9350',
    MockDataset.savingsCardId: '1174',
  };

  @override
  Future<List<PaymentCard>> fetchCards() async => MockDataset.cards;

  @override
  Future<String> revealPin(String cardId) async => _pins[cardId] ?? '0000';

  @override
  Future<PaymentCard> replaceCard(String cardId) async {
    final current = MockDataset.cardById(cardId);
    final now = _now ?? DateTime.now();
    final random = DateTime.now().microsecondsSinceEpoch % 9000;
    return current.copyWith(
      last4: (1000 + random).toString(),
      expiry: _fourYearsOut(now),
    );
  }

  static String _fourYearsOut(DateTime now) {
    final year = (now.year + 4) % 100;
    return '${now.month.toString().padLeft(2, '0')}/'
        '${year.toString().padLeft(2, '0')}';
  }
}

final cardsRepositoryProvider = Provider<CardsRepository>(
  (ref) => MockCardsRepository(now: ref.watch(nowProvider)()),
);

/// Cards reissued by [CardsRepository.replaceCard], keyed by card id.
///
/// Layered on top of the fixed mock cards the same way
/// [ledgerControllerProvider] layers onto the fixed mock transactions — the
/// seed data stays immutable, and this is what the user's own actions have
/// changed since.
class CardOverrides extends Notifier<Map<String, PaymentCard>> {
  @override
  Map<String, PaymentCard> build() => const {};

  void apply(PaymentCard replaced) {
    state = {...state, replaced.id: replaced};
  }
}

final cardOverridesProvider =
    NotifierProvider<CardOverrides, Map<String, PaymentCard>>(
      CardOverrides.new,
    );

/// The wallet's cards, with any reissued card swapped in and every holder
/// name overlaid to match whoever is actually signed in.
///
/// Only the printed name and (after a replacement) the number/expiry change —
/// balance, network and style stay exactly as the mock data defines them.
final cardsProvider = FutureProvider<List<PaymentCard>>((ref) async {
  final cards = await ref.watch(cardsRepositoryProvider).fetchCards();
  final overrides = ref.watch(cardOverridesProvider);
  final signedInUser = ref.watch(authControllerProvider).user;
  return [
    for (final card in cards)
      (overrides[card.id] ?? card).copyWith(
        holderName: signedInUser?.fullName,
      ),
  ];
});

/// Which card the carousel is showing.
class SelectedCardIndex extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (state != index) state = index;
  }
}

final selectedCardIndexProvider = NotifierProvider<SelectedCardIndex, int>(
  SelectedCardIndex.new,
);

/// Ids of cards the user has frozen — persisted via [AppPreferences], so it
/// survives an app restart the same way onboarding and the theme choice do.
class FrozenCards extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(appPreferencesProvider).frozenCardIds;

  void toggle(String cardId) {
    final next = state.contains(cardId)
        ? ({...state}..remove(cardId))
        : {...state, cardId};
    state = next;
    ref.read(appPreferencesProvider).setFrozenCardIds(next);
  }

  /// Called after a replacement — a newly issued card is never frozen.
  void unfreeze(String cardId) {
    if (!state.contains(cardId)) return;
    final next = {...state}..remove(cardId);
    state = next;
    ref.read(appPreferencesProvider).setFrozenCardIds(next);
  }

  bool isFrozen(String cardId) => state.contains(cardId);
}

final frozenCardsProvider = NotifierProvider<FrozenCards, Set<String>>(
  FrozenCards.new,
);
