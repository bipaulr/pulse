import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/features/transactions/data/transaction_query.dart';
import 'package:pulse/features/transactions/widgets/transaction_filter_bar.dart';
import 'package:pulse/features/transactions/widgets/transaction_search_field.dart';
import 'package:pulse/shared/data/mock_dataset.dart';
import 'package:pulse/shared/models/models.dart';

import 'support/pump_app.dart';

void main() {
  Future<void> openFeed(WidgetTester tester, {Size size = phoneSize}) async {
    await pumpPulseApp(
      tester,
      initialLocation: AppRoutes.transactions,
      size: size,
    );
  }

  /// Waits past the search field's debounce.
  Future<void> settleSearch(WidgetTester tester) async {
    await tester.pump(TransactionSearchField.debounce);
    await tester.pumpAndSettle();
  }

  group('Transactions feed', () {
    testWidgets('groups rows under day headers', (tester) async {
      await openFeed(tester);

      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('Swiggy'), findsOneWidget);
      expect(find.text('Amazon'), findsOneWidget);
      expect(find.text('- ₹420'), findsOneWidget);
    });

    testWidgets('search filters by merchant, after debouncing', (tester) async {
      await openFeed(tester);

      await tester.enterText(find.byType(TextField), 'netflix');
      // Before the debounce elapses the feed is untouched.
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Swiggy'), findsOneWidget);

      await settleSearch(tester);

      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Swiggy'), findsNothing);
    });

    testWidgets('search also matches category names', (tester) async {
      await openFeed(tester);

      await tester.enterText(find.byType(TextField), 'transport');
      await settleSearch(tester);

      expect(find.text('Uber'), findsOneWidget);
      expect(find.text('Amazon'), findsNothing);
    });

    testWidgets('a search with no hits offers a way out', (tester) async {
      await openFeed(tester);

      await tester.enterText(find.byType(TextField), 'zzzz');
      await settleSearch(tester);

      expect(find.text('No matching transactions'), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.text('Swiggy'), findsOneWidget);
    });

    testWidgets('filter chips narrow the feed immediately', (tester) async {
      await openFeed(tester);

      // "Income" is both a chip and a category label, so scope the finder.
      Finder chip(String label) => find.descendant(
        of: find.byType(TransactionFilterBar),
        matching: find.text(label),
      );

      await tester.tap(chip('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Swiggy'), findsNothing);

      await tester.tap(chip('All'));
      await tester.pumpAndSettle();
      expect(find.text('Swiggy'), findsOneWidget);
    });

    testWidgets('every filter renders without error', (tester) async {
      await openFeed(tester);

      // Driven through the provider rather than by tapping: the later chips
      // are off-screen in the horizontal bar and so are not built yet.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(TransactionFilterBar)),
      );

      for (final filter in TransactionFilter.values) {
        container.read(transactionQueryProvider.notifier).setFilter(filter);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: filter.label);
      }
    });

    testWidgets('tapping a row opens its details and back returns', (
      tester,
    ) async {
      await openFeed(tester);

      await tester.tap(find.text('Swiggy'));
      await tester.pumpAndSettle();

      expect(find.text('Transaction'), findsOneWidget);
      expect(find.text('Lunch order · 2 items'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('TXN_01'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Every movement across your cards'), findsOneWidget);
    });

    testWidgets('lays out without overflow across phone sizes', (tester) async {
      for (final size in const [
        Size(320, 640),
        Size(360, 800),
        Size(412, 915),
      ]) {
        await openFeed(tester, size: size);
        // The filter bar is also a ListView; the feed is the last one.
        await tester.drag(find.byType(ListView).last, const Offset(0, -1500));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });
  });

  group('feed grouping', () {
    test('labels today, yesterday and older days', () {
      final today = DateTime(2026, 8, 13);
      expect(dayLabel(today, today), 'TODAY');
      expect(dayLabel(DateTime(2026, 8, 12), today), 'YESTERDAY');
      expect(dayLabel(DateTime(2026, 8, 9), today), '9 AUGUST');
    });

    test('emits one header per day, in order', () {
      final dataset = MockDataset(now: testNow);
      final feed = buildTransactionFeed(dataset.transactions, testNow);

      expect(feed.first, isA<TransactionDayHeader>());
      expect((feed.first as TransactionDayHeader).label, 'TODAY');

      final headers = feed.whereType<TransactionDayHeader>().length;
      final entries = feed.whereType<TransactionEntry>().length;
      expect(entries, dataset.transactions.length);
      // One header per distinct day present in the data.
      expect(
        headers,
        dataset.transactions.map((t) => t.day).toSet().length,
      );
    });
  });

  group('filters', () {
    PulseTransaction sample(TransactionCategory category, double amount) =>
        PulseTransaction(
          id: 'x',
          merchant: 'Test',
          category: category,
          amount: amount,
          occurredAt: testNow,
          cardId: MockDataset.primaryCardId,
        );

    test('direction filters split income from spend', () {
      final income = sample(TransactionCategory.income, 100);
      final spend = sample(TransactionCategory.food, -100);

      expect(TransactionFilter.all.accepts(income), isTrue);
      expect(TransactionFilter.all.accepts(spend), isTrue);
      expect(TransactionFilter.income.accepts(income), isTrue);
      expect(TransactionFilter.income.accepts(spend), isFalse);
      expect(TransactionFilter.expenses.accepts(spend), isTrue);
      expect(TransactionFilter.expenses.accepts(income), isFalse);
    });

    test('category filters match their own category', () {
      expect(
        TransactionFilter.food.accepts(sample(TransactionCategory.food, -1)),
        isTrue,
      );
      expect(
        TransactionFilter.food.accepts(sample(TransactionCategory.bills, -1)),
        isFalse,
      );
    });

    test('search matches merchant or category, case-insensitively', () {
      final txn = sample(TransactionCategory.shopping, -100);
      expect(txn.matches(''), isTrue);
      expect(txn.matches('TES'), isTrue);
      expect(txn.matches('shopping'), isTrue);
      expect(txn.matches('food'), isFalse);
    });
  });
}
