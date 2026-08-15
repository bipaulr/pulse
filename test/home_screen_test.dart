import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/core/theme/pulse_theme.dart';
import 'package:pulse/shared/models/models.dart';
import 'package:pulse/shared/widgets/pulse_payment_card.dart';

import 'support/pump_app.dart';

/// The clock the sample data is pinned to.
final _now = testNow;

Future<void> pumpHome(WidgetTester tester, {Size size = phoneSize}) =>
    pumpPulseApp(tester, size: size);

void main() {
  group('Home screen', () {
    testWidgets('shows the greeting, balance and trend', (tester) async {
      await pumpHome(tester);

      expect(find.text('Hi, Aarav'), findsOneWidget);
      expect(find.text('Total Balance'), findsOneWidget);
      expect(find.text('₹42,850.00'), findsOneWidget);
      expect(find.text('+12.4% this month'), findsOneWidget);
    });

    testWidgets('renders the payment card with masked details', (tester) async {
      await pumpHome(tester);

      expect(find.byType(PulsePaymentCard), findsOneWidget);
      expect(find.text('Pulse'), findsOneWidget);
      expect(find.text('VIRTUAL DEBIT'), findsOneWidget);
      expect(find.text('••••  ••••  ••••  4921'), findsOneWidget);
      expect(find.text('Aarav Sharma'), findsOneWidget);
      expect(find.text('02/28'), findsOneWidget);
    });

    testWidgets('shows all four quick actions', (tester) async {
      await pumpHome(tester);

      for (final label in ['Deposit', 'Transfer', 'Withdraw', 'More']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('quick actions admit they do nothing yet', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Deposit'));
      await tester.pump();

      expect(find.text('Deposit is coming soon'), findsOneWidget);
    });

    testWidgets('lists the recent transactions', (tester) async {
      await pumpHome(tester);

      // Scroll the section fully into view before asserting on its rows.
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Swiggy'), findsOneWidget);
      expect(find.text('Amazon'), findsOneWidget);
      expect(find.text('Uber'), findsOneWidget);
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);

      // Whole amounts drop the decimals; income is signed positive.
      expect(find.text('- ₹420'), findsOneWidget);
      expect(find.text('- ₹1,299'), findsOneWidget);
      expect(find.text('+ ₹45,000'), findsOneWidget);
    });

    testWidgets('tints income green and leaves spend neutral', (tester) async {
      await pumpHome(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      final income = tester.widget<Text>(find.text('+ ₹45,000'));
      final spend = tester.widget<Text>(find.text('- ₹420'));

      expect(income.style?.color, PulseColors.light.positive);
      expect(spend.style?.color, PulseColors.light.textPrimary);
    });

    testWidgets('View All opens the transactions tab', (tester) async {
      await pumpHome(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsWidgets);
      expect(find.text('Every movement across your cards'), findsOneWidget);
    });

    testWidgets('lays out without overflow across phone sizes', (tester) async {
      for (final size in const [
        Size(320, 640), // narrow, small
        Size(360, 800), // common budget Android
        Size(412, 915), // Pixel-class
      ]) {
        await pumpHome(tester, size: size);
        await tester.drag(find.byType(ListView), const Offset(0, -800));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });
  });

  group('Logout', () {
    testWidgets('the avatar opens a profile sheet with the signed-in name', (
      tester,
    ) async {
      await pumpHome(tester);

      await tester.tap(find.text('AS'));
      await tester.pumpAndSettle();

      expect(find.text('Aarav Sharma'), findsWidgets);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('Cancel dismisses the sheet without logging out', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.text('AS'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Log Out'), findsNothing);
      expect(find.text('Hi, Aarav'), findsOneWidget);
    });

    testWidgets('Log Out clears the session and returns to Login', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.text('AS'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets(
      'after logging out, a protected route is no longer reachable',
      (tester) async {
        await pumpHome(tester);
        await tester.tap(find.text('AS'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();
        expect(find.text('Welcome back'), findsOneWidget);

        // Simulates a stale deep link or a typed URL to a protected tab,
        // in the same session that just logged out.
        final router = GoRouter.of(tester.element(find.byType(Navigator).first));
        router.go(AppRoutes.cards);
        await tester.pumpAndSettle();

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('My Cards'), findsNothing);
      },
    );
  });

  group('models', () {
    test('balance summary formats its trend', () {
      expect(
        const BalanceSummary(total: 1, changePercent: 12.4).changeLabel,
        '+12.4% this month',
      );
      expect(
        const BalanceSummary(total: 1, changePercent: -3).changeLabel,
        '−3.0% this month',
      );
    });

    test('transactions collapse whole amounts to zero decimals', () {
      PulseTransaction at(double amount) => PulseTransaction(
        id: 'x',
        merchant: 'm',
        category: TransactionCategory.food,
        amount: amount,
        occurredAt: _now,
        cardId: 'card_lime',
      );

      expect(at(-420).displayDecimals, 0);
      expect(at(-420.5).displayDecimals, 2);
      expect(at(45000).isIncome, isTrue);
      expect(at(-1).isIncome, isFalse);
    });

    test('timestamps stay short', () {
      PulseTransaction at(DateTime when) => PulseTransaction(
        id: 'x',
        merchant: 'm',
        category: TransactionCategory.food,
        amount: -1,
        occurredAt: when,
        cardId: 'card_lime',
      );

      expect(at(DateTime(2026, 8, 13, 13, 12)).shortWhenLabel(_now), '1:12 PM');
      expect(at(DateTime(2026, 8, 13, 9, 5)).shortWhenLabel(_now), '9:05 AM');
      expect(at(DateTime(2026, 8, 13, 0, 30)).shortWhenLabel(_now), '12:30 AM');
      expect(at(DateTime(2026, 8, 12, 18)).shortWhenLabel(_now), 'Yesterday');
      expect(at(DateTime(2026, 8, 9, 18)).shortWhenLabel(_now), '9 Aug');
    });

    test('card exposes only the last four digits', () {
      const card = PaymentCard(
        id: 'c',
        holderName: 'Aarav Sharma',
        last4: '4921',
        expiry: '02/28',
        availableBalance: 42850,
      );
      expect(card.maskedNumber, '••••  ••••  ••••  4921');
    });

    test('profile derives initials', () {
      const user = UserProfile(firstName: 'Aarav', lastName: 'Sharma');
      expect(user.initials, 'AS');
      expect(user.fullName, 'Aarav Sharma');
      expect(
        const UserProfile(firstName: '', lastName: '').initials,
        isEmpty,
      );
    });
  });
}
