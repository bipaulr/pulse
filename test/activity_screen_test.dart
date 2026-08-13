import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/features/activity/data/activity_analytics.dart';
import 'package:pulse/features/activity/data/activity_models.dart';
import 'package:pulse/features/activity/data/activity_providers.dart';
import 'package:pulse/shared/data/mock_dataset.dart';
import 'package:pulse/shared/models/models.dart';
import 'package:pulse/shared/widgets/pulse_spending_chart.dart';

import 'support/pump_app.dart';

PulseTransaction txn({
  required String id,
  required String merchant,
  required TransactionCategory category,
  required double amount,
  required DateTime at,
}) => PulseTransaction(
  id: id,
  merchant: merchant,
  category: category,
  amount: amount,
  occurredAt: at,
  cardId: MockDataset.primaryCardId,
);

void main() {
  // 13 Aug 2026. August is the current bucket, July the previous one.
  final now = testNow;

  final sample = <PulseTransaction>[
    txn(
      id: 'a',
      merchant: 'Swiggy',
      category: TransactionCategory.food,
      amount: -400,
      at: DateTime(2026, 8, 10),
    ),
    txn(
      id: 'b',
      merchant: 'Amazon',
      category: TransactionCategory.shopping,
      amount: -600,
      at: DateTime(2026, 8, 5),
    ),
    txn(
      id: 'c',
      merchant: 'Salary',
      category: TransactionCategory.income,
      amount: 5000,
      at: DateTime(2026, 8, 1),
    ),
    txn(
      id: 'd',
      merchant: 'Zara',
      category: TransactionCategory.shopping,
      amount: -500,
      at: DateTime(2026, 7, 20),
    ),
  ];

  ActivitySummary summarize({
    List<PulseTransaction>? transactions,
    ActivityPeriod period = ActivityPeriod.month,
    CategoryDirection direction = CategoryDirection.expense,
  }) => ActivityAnalytics.summarize(
    transactions: transactions ?? sample,
    period: period,
    now: now,
    direction: direction,
  );

  group('analytics totals', () {
    test('sums spending as a positive magnitude, excluding income', () {
      expect(summarize().totalSpending, 1500);
    });

    test('sums income separately', () {
      expect(summarize().totalIncome, 5000);
    });

    test('counts only spending transactions and averages them', () {
      final summary = summarize();
      expect(summary.transactionCount, 3);
      expect(summary.averageTransaction, 500);
    });

    test('finds the largest single outflow', () {
      expect(summarize().largestTransaction?.merchant, 'Amazon');
    });

    test('an empty dataset yields zeroes but keeps the chart axis', () {
      final summary = summarize(transactions: const []);

      expect(summary.totalSpending, 0);
      expect(summary.totalIncome, 0);
      expect(summary.transactionCount, 0);
      expect(summary.averageTransaction, 0);
      expect(summary.largestTransaction, isNull);
      expect(summary.categories, isEmpty);
      expect(summary.recentTransfers, isEmpty);
      expect(summary.isEmpty, isTrue);
      // Buckets survive so the chart still draws.
      expect(summary.buckets, hasLength(ActivityPeriod.month.bucketCount));
    });
  });

  group('monthly aggregation', () {
    test('buckets spending into the right months', () {
      final summary = summarize();
      final august = summary.buckets.last;
      final july = summary.buckets[summary.buckets.length - 2];

      expect(august.label, 'Aug');
      expect(august.amount, 1000);
      expect(july.label, 'Jul');
      expect(july.amount, 500);
      // Income never lands in a spending bucket.
      expect(
        summary.buckets.fold<double>(0, (sum, b) => sum + b.amount),
        1500,
      );
    });

    test('each period produces its own bucket count and labels', () {
      expect(
        summarize(period: ActivityPeriod.week).buckets,
        hasLength(ActivityPeriod.week.bucketCount),
      );
      expect(
        summarize(period: ActivityPeriod.quarter).buckets.last.label,
        'Q3',
      );
      expect(
        summarize(period: ActivityPeriod.year).buckets.last.label,
        '2026',
      );
    });
  });

  group('percentage change', () {
    test('compares the last bucket with the one before it', () {
      // July 500 -> August 1000 is +100%.
      expect(summarize().changePercent, 100);
    });

    test('handles a zero baseline and short series', () {
      expect(ActivityAnalytics.percentChange([0, 250]), 100);
      expect(ActivityAnalytics.percentChange([0, 0]), 0);
      expect(ActivityAnalytics.percentChange([400]), 0);
      expect(ActivityAnalytics.percentChange(const []), 0);
      expect(ActivityAnalytics.percentChange([400, 300]), -25);
    });

    test('formats the change for display', () {
      expect(summarize().changeLabel, '+100.0% this month');
    });
  });

  group('category aggregation', () {
    test('groups expenses by category, largest first, with shares', () {
      final categories = summarize().categories;

      expect(categories.map((c) => c.label), ['Shopping', 'Food']);
      expect(categories.first.amount, 1100);
      expect(categories.first.transactionCount, 2);
      expect(categories.first.share, closeTo(1100 / 1500, 0.0001));
      expect(categories.first.sharePercentLabel, '73%');
      expect(categories.last.category, TransactionCategory.food);
    });

    test('groups income by source instead of category', () {
      final categories = summarize(
        direction: CategoryDirection.income,
      ).categories;

      expect(categories, hasLength(1));
      expect(categories.first.label, 'Salary');
      expect(categories.first.amount, 5000);
      expect(categories.first.category, isNull);
    });

    test('shares always sum to one', () {
      final total = summarize().categories.fold<double>(
        0,
        (sum, c) => sum + c.share,
      );
      expect(total, closeTo(1.0, 0.0001));
    });
  });

  group('Activity screen', () {
    Future<void> openActivity(WidgetTester tester, {Size size = phoneSize}) =>
        pumpPulseApp(tester, initialLocation: AppRoutes.activity, size: size);

    testWidgets('renders the full hierarchy', (tester) async {
      await openActivity(tester);

      expect(find.text('Activity'), findsWidgets);
      expect(find.text('Total Spending'), findsOneWidget);
      expect(find.byType(PulseSpendingChart), findsOneWidget);
      expect(find.text('Income'), findsWidgets);
      expect(find.text('Expense'), findsWidgets);

      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Recent Transfer'), findsOneWidget);
    });

    testWidgets('the chart plots one bar per bucket', (tester) async {
      await openActivity(tester);

      final chart = tester.widget<PulseSpendingChart>(
        find.byType(PulseSpendingChart),
      );
      expect(chart.bars, hasLength(ActivityPeriod.month.bucketCount));
      // Newest bucket is selected by default.
      expect(chart.selectedIndex, ActivityPeriod.month.bucketCount - 1);
    });

    testWidgets('selecting a bar retargets the chart readout only', (
      tester,
    ) async {
      await openActivity(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PulseSpendingChart)),
      );
      final bars = tester
          .widget<PulseSpendingChart>(find.byType(PulseSpendingChart))
          .bars;

      // Newest bucket is read out by default.
      expect(find.text('Spending · ${bars.last.label}'), findsOneWidget);

      container.read(selectedBucketIndexProvider.notifier).select(0);
      await tester.pumpAndSettle();

      expect(container.read(resolvedBucketIndexProvider), 0);
      expect(find.text('Spending · ${bars.first.label}'), findsOneWidget);
      expect(find.text('Spending · ${bars.last.label}'), findsNothing);

      // The headline stays the window total, so it never contradicts the
      // Expense tile below it.
      expect(find.text('Total Spending'), findsOneWidget);
      expect(
        tester
            .widget<PulseSpendingChart>(find.byType(PulseSpendingChart))
            .selectedIndex,
        0,
      );
    });

    testWidgets('changing period rebuilds the chart and clears selection', (
      tester,
    ) async {
      await openActivity(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PulseSpendingChart)),
      );
      container.read(selectedBucketIndexProvider.notifier).select(0);
      await tester.pumpAndSettle();

      container.read(activityPeriodProvider.notifier).select(
        ActivityPeriod.year,
      );
      await tester.pumpAndSettle();

      // Selection is dropped, because index 0 meant a different bucket.
      expect(container.read(selectedBucketIndexProvider), isNull);

      final chart = tester.widget<PulseSpendingChart>(
        find.byType(PulseSpendingChart),
      );
      expect(chart.bars, hasLength(ActivityPeriod.year.bucketCount));
      expect(chart.bars.last.label, '${testNow.year}');
    });

    testWidgets('the category filter switches expense and income', (
      tester,
    ) async {
      await openActivity(tester);
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PulseSpendingChart)),
      );
      expect(container.read(categoryDirectionProvider), CategoryDirection.expense);

      container
          .read(categoryDirectionProvider.notifier)
          .select(CategoryDirection.income);
      await tester.pumpAndSettle();

      // Income groups by source, so payroll shows as its own card.
      expect(find.text('Salary'), findsWidgets);
    });

    testWidgets('the period sheet opens and picks without overflowing', (
      tester,
    ) async {
      // Deliberately the shortest supported window — this is where the sheet
      // overflowed before it was made scrollable.
      await openActivity(tester, size: const Size(320, 640));

      await tester.tap(find.text('Month'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Show spending by'), findsOneWidget);
      for (final period in ActivityPeriod.values) {
        expect(find.text(period.label), findsWidgets);
      }

      await tester.tap(find.text('Quarter'));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PulseSpendingChart)),
      );
      expect(container.read(activityPeriodProvider), ActivityPeriod.quarter);
      expect(tester.takeException(), isNull);
    });

    testWidgets('View All leaves for the transactions feed', (tester) async {
      await openActivity(tester);
      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.text('Every movement across your cards'), findsOneWidget);
    });

    testWidgets('lays out without overflow across widths', (tester) async {
      for (final size in const [
        Size(320, 640),
        Size(360, 800),
        Size(390, 844),
        Size(412, 915),
        Size(1280, 900), // desktop Chrome
      ]) {
        await openActivity(tester, size: size);
        await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });

    testWidgets('constrains its content on a desktop-width window', (
      tester,
    ) async {
      await openActivity(tester, size: const Size(1280, 900));

      final chartWidth = tester.getSize(find.byType(PulseSpendingChart)).width;
      expect(chartWidth, lessThan(560));
    });
  });
}
