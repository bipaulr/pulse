import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';

import 'support/pump_app.dart';

void main() {
  Future<void> openOnboarding(WidgetTester tester) => pumpPulseApp(
    tester,
    authenticated: false,
    onboardingComplete: false,
  );

  group('Onboarding', () {
    testWidgets('starts on the first page with Skip visible', (tester) async {
      await openOnboarding(tester);

      expect(find.text('Your money, at a glance.'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('Next advances through every page in order', (tester) async {
      await openOnboarding(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Understand where it goes.'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Everything in one place.'), findsOneWidget);
      // The final page trades Next/Skip for a single Get Started action.
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('swiping also advances the page', (tester) async {
      await openOnboarding(tester);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Understand where it goes.'), findsOneWidget);
    });

    testWidgets('a back control returns to the previous page', (
      tester,
    ) async {
      await openOnboarding(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Your money, at a glance.'), findsOneWidget);
    });

    testWidgets('Skip completes onboarding and reaches Login directly', (
      tester,
    ) async {
      await openOnboarding(tester);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('Get Started on the final page completes onboarding too', (
      tester,
    ) async {
      await openOnboarding(tester);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets(
      'a returning, logged-out user never sees onboarding again',
      (tester) async {
        // onboardingComplete: true (default) simulates "already seen it".
        await pumpPulseApp(tester, authenticated: false);

        expect(find.text('Welcome back'), findsOneWidget);
        expect(find.text('Your money, at a glance.'), findsNothing);
      },
    );

    testWidgets(
      'lays out without overflow on every page, across phone sizes',
      (tester) async {
        for (final size in const [
          Size(320, 640),
          Size(360, 800),
          Size(412, 915),
        ]) {
          await pumpPulseApp(
            tester,
            authenticated: false,
            onboardingComplete: false,
            size: size,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'page 1 overflowed at ${size.width}x${size.height}',
          );

          // Each page has its own illustration, so all three must be visited.
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'page 2 overflowed at ${size.width}x${size.height}',
          );

          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'page 3 overflowed at ${size.width}x${size.height}',
          );
        }
      },
    );
  });

  group('routing', () {
    testWidgets(
      'visiting a protected route while unauthenticated and un-onboarded '
      'redirects to Onboarding',
      (tester) async {
        await pumpPulseApp(
          tester,
          authenticated: false,
          onboardingComplete: false,
          initialLocation: AppRoutes.home,
        );

        expect(find.text('Your money, at a glance.'), findsOneWidget);
      },
    );
  });
}
