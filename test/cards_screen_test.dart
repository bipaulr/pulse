import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/features/cards/data/cards_repository.dart';
import 'package:pulse/features/cards/widgets/card_actions.dart';
import 'package:pulse/features/cards/widgets/card_carousel.dart';
import 'package:pulse/shared/data/mock_dataset.dart';
import 'package:pulse/shared/widgets/pulse_payment_card.dart';

import 'support/pump_app.dart';

void main() {
  Future<void> openCards(WidgetTester tester) async {
    await pumpPulseApp(tester, initialLocation: AppRoutes.cards);
  }

  group('Cards screen', () {
    testWidgets('shows the wallet header and the first card', (tester) async {
      await openCards(tester);

      expect(find.text('My Cards'), findsOneWidget);
      expect(find.text('3 active'), findsOneWidget);
      expect(find.byType(CardCarousel), findsOneWidget);
      // The carousel keeps neighbours partly visible.
      expect(find.byType(PulsePaymentCard), findsWidgets);
      expect(find.text('••••  ••••  ••••  4921'), findsWidgets);
    });

    testWidgets('shows the selected card details', (tester) async {
      await openCards(tester);

      expect(find.text('Card Details'), findsOneWidget);
      expect(find.text('Card Number'), findsOneWidget);
      expect(find.text('Expiry Date'), findsOneWidget);
      expect(find.text('Card Holder'), findsWidgets);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.text('Pulse Network'), findsOneWidget);
    });

    testWidgets('swiping the carousel selects the next card', (tester) async {
      await openCards(tester);

      await tester.drag(find.byType(CardCarousel), const Offset(-400, 0));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CardCarousel)),
      );
      expect(container.read(selectedCardIndexProvider), 1);

      // Details follow the selection.
      expect(find.text('11/27'), findsWidgets);
    });

    testWidgets('freeze toggles the card state and its label', (tester) async {
      await openCards(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Freeze Card'), findsOneWidget);
      await tester.tap(find.text('Freeze Card'));
      await tester.pumpAndSettle();

      expect(find.text('Unfreeze'), findsOneWidget);

      // Scroll back up: the carousel is off-screen while the actions are in
      // view, so its frozen marker only exists once it is rebuilt.
      await tester.drag(find.byType(ListView), const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(find.text('Frozen'), findsWidgets);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(CardCarousel)),
      );
      expect(
        container.read(frozenCardsProvider),
        contains(MockDataset.primaryCardId),
      );
    });

    testWidgets('View PIN reveals a PIN and hides it again', (tester) async {
      await openCards(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('CARD PIN'), findsNothing);

      await tester.tap(find.text('View PIN'));
      await tester.pumpAndSettle();

      expect(find.text('CARD PIN'), findsOneWidget);
      expect(find.text('4  8  2  1'), findsOneWidget);
      expect(find.text('Hide PIN'), findsOneWidget);

      // It times itself out rather than lingering on screen.
      await tester.pump(CardActions.pinVisibleFor + const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('CARD PIN'), findsNothing);
    });

    testWidgets('Replace Card asks for confirmation first', (tester) async {
      await openCards(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Replace Card'));
      await tester.pumpAndSettle();

      expect(find.text('Replace this card?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Replace this card?'), findsNothing);
    });

    testWidgets('card activity links through to the feed', (tester) async {
      await openCards(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Card Activity'), findsOneWidget);

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.text('Every movement across your cards'), findsOneWidget);
    });

    testWidgets('lays out without overflow across phone sizes', (tester) async {
      for (final size in const [
        Size(320, 640),
        Size(360, 800),
        Size(412, 915),
      ]) {
        await pumpPulseApp(
          tester,
          initialLocation: AppRoutes.cards,
          size: size,
        );
        await tester.drag(find.byType(ListView), const Offset(0, -1200));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });
  });
}
