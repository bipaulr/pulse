import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/persistence/app_preferences.dart';
import 'package:pulse/features/auth/data/auth_controller.dart';
import 'package:pulse/features/auth/data/auth_repository.dart';
import 'package:pulse/features/auth/data/auth_state.dart';
import 'package:pulse/shared/data/mock_dataset.dart';

import 'support/in_memory_app_preferences.dart';
import 'support/pump_app.dart';

void main() {
  group('Personalization', () {
    testWidgets('the demo account greets as Aarav — an intentionally kept '
        'identity, not an unrelated hardcoded one', (tester) async {
      // Default pumpPulseApp session already *is* the demo identity; this
      // pins down that Home's greeting is reading it from auth state, not
      // coincidentally matching MockDataset on its own.
      await pumpPulseApp(tester);
      expect(find.text('Hi, Aarav'), findsOneWidget);
    });

    testWidgets("a freshly signed-up name reaches Home's greeting", (
      tester,
    ) async {
      await pumpPulseApp(
        tester,
        authenticated: false,
        initialLocation: '/sign-up',
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Maya Kapoor');
      await tester.enterText(fields.at(1), 'maya@example.com');
      await tester.enterText(fields.at(2), 'pulse1234');
      await tester.enterText(fields.at(3), 'pulse1234');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Hi, Maya'), findsOneWidget);
      expect(find.text('Hi, Aarav'), findsNothing);
    });

    testWidgets(
      "a signed-up name also becomes the cardholder name on every card — "
      "Home's hero card and every card in the wallet",
      (tester) async {
        await pumpPulseApp(
          tester,
          authenticated: false,
          initialLocation: '/sign-up',
        );

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'Maya Kapoor');
        await tester.enterText(fields.at(1), 'maya@example.com');
        await tester.enterText(fields.at(2), 'pulse1234');
        await tester.enterText(fields.at(3), 'pulse1234');
        await tester.tap(find.text('Create Account'));
        await tester.pump();
        await tester.pumpAndSettle();

        // Home's hero card.
        expect(find.text('Maya Kapoor'), findsOneWidget);
        expect(find.text('Aarav Sharma'), findsNothing);

        // Every card in the wallet — not just the first one.
        await tester.tap(find.byIcon(Icons.credit_card_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Maya Kapoor'), findsWidgets);
        expect(find.text('Aarav Sharma'), findsNothing);

        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
        expect(find.text('Maya Kapoor'), findsWidgets);

        await tester.drag(find.byType(PageView), const Offset(-400, 0));
        await tester.pumpAndSettle();
        expect(find.text('Maya Kapoor'), findsWidgets);
      },
    );

    testWidgets(
      "financial data — balance, transactions, merchants — does not change "
      "just because a different name signed up",
      (tester) async {
        await pumpPulseApp(
          tester,
          authenticated: false,
          initialLocation: '/sign-up',
        );

        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'Maya Kapoor');
        await tester.enterText(fields.at(1), 'maya@example.com');
        await tester.enterText(fields.at(2), 'pulse1234');
        await tester.enterText(fields.at(3), 'pulse1234');
        await tester.tap(find.text('Create Account'));
        await tester.pump();
        await tester.pumpAndSettle();

        // Same balance and the same mock transactions regardless of identity.
        expect(find.text('₹42,850.00'), findsOneWidget);
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(find.text('Swiggy'), findsOneWidget);
        expect(find.text('- ₹420'), findsOneWidget);
      },
    );

    testWidgets('logout clears the greeting and the session identity', (
      tester,
    ) async {
      await pumpPulseApp(tester);
      expect(find.text('Hi, Aarav'), findsOneWidget);

      await tester.tap(find.text('AS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Hi, Aarav'), findsNothing);
    });
  });

  group('Persistence', () {
    test('a signed-up identity survives the app being recreated', () async {
      // The same AppPreferences instance simulates the on-disk store
      // surviving a reload; a *new* ProviderContainer simulates the app
      // process restarting on top of it.
      final store = InMemoryAppPreferences(onboardingComplete: true);

      final firstRun = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(store)],
      );
      await firstRun
          .read(authControllerProvider.notifier)
          .signUp(
            name: 'Maya Kapoor',
            email: 'maya@example.com',
            password: 'pulse1234',
          );
      expect(
        firstRun.read(authControllerProvider).user?.fullName,
        'Maya Kapoor',
      );
      firstRun.dispose();

      final secondRun = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(store)],
      );
      addTearDown(secondRun.dispose);

      final restored = secondRun.read(authControllerProvider);
      expect(restored.status, AuthStatus.authenticated);
      expect(restored.user?.fullName, 'Maya Kapoor');
    });

    test('logout persists too — a recreated app stays logged out', () async {
      final store = InMemoryAppPreferences(
        onboardingComplete: true,
        session: const AuthSession(
          firstName: 'Aarav',
          lastName: 'Sharma',
          email: MockAuthRepository.demoEmail,
        ),
      );

      final firstRun = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(store)],
      );
      await firstRun.read(authControllerProvider.notifier).logout();
      firstRun.dispose();

      final secondRun = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(store)],
      );
      addTearDown(secondRun.dispose);

      expect(
        secondRun.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
    });
  });

  group('models', () {
    test('the mock dataset itself is identity-agnostic financial data', () {
      // MockDataset.user is a demo fixture — overlaid by whoever actually
      // signs in, never the source of truth for who's logged in.
      expect(MockDataset.user.fullName, 'Aarav Sharma');
      expect(MockDataset.cards, hasLength(3));
      for (final card in MockDataset.cards) {
        expect(card.holderName, 'Aarav Sharma');
      }
    });
  });
}
