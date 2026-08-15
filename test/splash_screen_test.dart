import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/app.dart';
import 'package:pulse/core/clock.dart';
import 'package:pulse/core/persistence/app_preferences.dart';
import 'package:pulse/features/auth/splash_screen.dart';

import 'support/in_memory_app_preferences.dart';
import 'support/pump_app.dart';

void main() {
  group('Splash', () {
    testWidgets('renders the brand mark before it navigates away', (
      tester,
    ) async {
      tester.view.physicalSize = phoneSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Splash's real (non-zero) duration is used here on purpose, so there
      // is a window to see it before the automatic navigation fires.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nowProvider.overrideWithValue(() => testNow),
            appPreferencesProvider.overrideWithValue(
              InMemoryAppPreferences(session: testSession),
            ),
          ],
          child: const PulseApp(),
        ),
      );
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Pulse'), findsOneWidget);
      expect(find.text('Clarity for your money'), findsOneWidget);
    });

    testWidgets('an authenticated session lands on Home', (tester) async {
      await pumpPulseApp(tester);

      expect(find.text('Hi, Aarav'), findsOneWidget);
    });

    testWidgets(
      'no session but onboarding already seen lands on Login',
      (tester) async {
        await pumpPulseApp(tester, authenticated: false);

        expect(find.text('Welcome back'), findsOneWidget);
      },
    );

    testWidgets(
      'a first-time visitor (no session, no onboarding) lands on Onboarding',
      (tester) async {
        await pumpPulseApp(
          tester,
          authenticated: false,
          onboardingComplete: false,
        );

        expect(find.text('Your money, at a glance.'), findsOneWidget);
      },
    );
  });
}
