import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/app.dart';
import 'package:pulse/core/clock.dart';
import 'package:pulse/core/persistence/app_preferences.dart';
import 'package:pulse/features/auth/data/auth_repository.dart';
import 'package:pulse/features/auth/splash_screen.dart';

import 'in_memory_app_preferences.dart';

/// A clock the mock data is pinned to, so relative timestamps are stable.
final testNow = DateTime(2026, 8, 13, 15, 30);

/// Pulse is a phone app, so tests run on a phone-shaped surface rather than
/// the 800x600 default — on which the aspect-ratio'd cards would be enormous.
const phoneSize = Size(390, 844);

/// The identity `pumpPulseApp`'s default session signs in as — the same
/// demo user [MockAuthRepository.login] returns, so Home's greeting and any
/// screen reached via [initialLocation] agree with each other.
final testSession = AuthSession(
  firstName: 'Aarav',
  lastName: 'Sharma',
  email: MockAuthRepository.demoEmail,
);

/// Boots the real app with the mock data pinned to [testNow].
///
/// Defaults to an already-authenticated, already-onboarded session and skips
/// the splash delay, so most tests land straight on [initialLocation] the way
/// they did before auth existed. Pass `authenticated: false` and/or
/// `onboardingComplete: false` to exercise the splash/onboarding/login flow
/// itself instead.
Future<void> pumpPulseApp(
  WidgetTester tester, {
  String? initialLocation,
  Size size = phoneSize,
  bool authenticated = true,
  bool onboardingComplete = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      // A fresh key forces Flutter to discard the previous element tree
      // instead of reconciling into it — without this, calling pumpPulseApp
      // a second time in the same test (e.g. looping over viewport sizes)
      // reuses old State objects wholesale (PageView position, text field
      // contents, ...) rather than actually rebooting the app.
      key: UniqueKey(),
      overrides: [
        // One clock override pins the sample data *and* the grouping, so day
        // labels like "Today" cannot drift apart as the real date moves on.
        nowProvider.overrideWithValue(() => testNow),
        appPreferencesProvider.overrideWithValue(
          InMemoryAppPreferences(
            onboardingComplete: onboardingComplete,
            session: authenticated ? testSession : null,
          ),
        ),
        // Real screens never wait out Splash's entrance on purpose.
        splashDurationProvider.overrideWithValue(Duration.zero),
      ],
      child: const PulseApp(),
    ),
  );
  await tester.pumpAndSettle();

  if (initialLocation != null) {
    GoRouter.of(
      tester.element(find.byType(Navigator).first),
    ).go(initialLocation);
    await tester.pumpAndSettle();
  }
}
