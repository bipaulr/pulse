import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_dataset.dart';
import '../../../shared/models/models.dart';

/// Source of the user's cards.
///
/// [revealPin] is a method rather than a field on [PaymentCard] on purpose: a
/// PIN is fetched on demand and never held in the model, which is how a real
/// issuer integration has to work.
abstract interface class CardsRepository {
  Future<List<PaymentCard>> fetchCards();

  Future<String> revealPin(String cardId);
}

class MockCardsRepository implements CardsRepository {
  const MockCardsRepository();

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
}

final cardsRepositoryProvider = Provider<CardsRepository>(
  (ref) => const MockCardsRepository(),
);

final cardsProvider = FutureProvider<List<PaymentCard>>(
  (ref) => ref.watch(cardsRepositoryProvider).fetchCards(),
);

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

/// Ids of cards the user has frozen.
///
/// Local-only for now; Phase 5 will push this through the repository.
class FrozenCards extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String cardId) {
    state = state.contains(cardId)
        ? ({...state}..remove(cardId))
        : {...state, cardId};
  }

  bool isFrozen(String cardId) => state.contains(cardId);
}

final frozenCardsProvider = NotifierProvider<FrozenCards, Set<String>>(
  FrozenCards.new,
);
