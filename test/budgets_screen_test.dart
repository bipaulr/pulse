import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/features/budgets/data/budgets_repository.dart';
import 'package:pulse/features/budgets/widgets/budget_progress_card.dart';
import 'package:pulse/shared/models/models.dart';

import 'support/pump_app.dart';

void main() {
  Future<void> openBudgets(WidgetTester tester) async {
    await pumpPulseApp(tester, initialLocation: AppRoutes.budgets);
  }

  group('Budgets screen', () {
    testWidgets('shows the header and the seeded budgets', (tester) async {
      await openBudgets(tester);

      expect(find.text('Budgets'), findsOneWidget);
      expect(find.text('Spent this month'), findsOneWidget);
      expect(find.byType(BudgetProgressCard), findsWidgets);
      expect(find.text('Food'), findsWidgets);
    });

    testWidgets('unbudgeted categories show up as add chips', (tester) async {
      await openBudgets(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Add a Budget'), findsOneWidget);
      // Health has no seeded budget, so it should offer a chip to add one.
      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('tapping an existing budget opens the edit sheet prefilled', (
      tester,
    ) async {
      await openBudgets(tester);

      await tester.tap(find.text('Food').first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Food Budget'), findsOneWidget);
      expect(find.text('8000'), findsOneWidget);
    });

    testWidgets('saving a new limit updates the card and persists in state', (
      tester,
    ) async {
      await openBudgets(tester);

      await tester.tap(find.text('Food').first);
      await tester.pumpAndSettle();

      final field = find.widgetWithText(TextField, '8000');
      await tester.enterText(field, '9500');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Food budget set to ₹9500'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BudgetProgressCard).first),
      );
      expect(
        container.read(budgetOverridesProvider)[TransactionCategory.food],
        9500,
      );
    });

    testWidgets('removing a budget takes it out of the progress list', (
      tester,
    ) async {
      await openBudgets(tester);

      await tester.tap(find.text('Food').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Food budget removed'), findsOneWidget);
      expect(find.text('Edit Food Budget'), findsNothing);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ListView)),
      );
      expect(container.read(budgetOverridesProvider)[TransactionCategory.food], 0);
    });

    testWidgets('adding a budget for an unbudgeted category', (tester) async {
      await openBudgets(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      expect(find.text('Set Health Budget'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1500');
      await tester.tap(find.text('Save Budget'));
      await tester.pumpAndSettle();

      expect(find.text('Health budget set to ₹1500'), findsOneWidget);
    });
  });
}
