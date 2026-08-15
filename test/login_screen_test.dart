import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/features/auth/data/auth_repository.dart';

import 'support/pump_app.dart';

/// The email/password fields, in the order they appear on screen.
Finder loginFields() => find.byType(TextField);

void main() {
  Future<void> openLogin(WidgetTester tester) =>
      pumpPulseApp(tester, authenticated: false);

  group('Login', () {
    testWidgets('renders the form', (tester) async {
      await openLogin(tester);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(loginFields(), findsNWidgets(2));
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      // The demo credentials are surfaced so a reviewer can log in without
      // reading the README.
      expect(find.textContaining(MockAuthRepository.demoEmail), findsOneWidget);
    });

    testWidgets('shows validation errors only after a submit attempt', (
      tester,
    ) async {
      await openLogin(tester);

      expect(find.text('Enter your email.'), findsNothing);

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
    });

    testWidgets('the password field can be revealed and hidden', (
      tester,
    ) async {
      await openLogin(tester);

      final passwordField = tester.widget<TextField>(loginFields().at(1));
      expect(passwordField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final revealed = tester.widget<TextField>(loginFields().at(1));
      expect(revealed.obscureText, isFalse);
    });

    testWidgets('a wrong password shows an inline error and stays on Login', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.enterText(loginFields().at(0), MockAuthRepository.demoEmail);
      await tester.enterText(loginFields().at(1), 'totally-wrong');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('the demo credentials log in and reach Home', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.enterText(loginFields().at(0), MockAuthRepository.demoEmail);
      await tester.enterText(loginFields().at(1), MockAuthRepository.demoPassword);
      await tester.tap(find.text('Log In'));
      await tester.pump(); // authenticating…
      await tester.pumpAndSettle(); // …then the router redirect lands on Home.

      expect(find.text('Hi, Aarav'), findsOneWidget);
    });

    testWidgets('editing a field after a failed attempt clears the error', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.enterText(loginFields().at(0), MockAuthRepository.demoEmail);
      // Long enough to clear client-side length validation and reach the
      // repository, which is what actually produces this error.
      await tester.enterText(loginFields().at(1), 'wrong-password');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect email or password.'), findsOneWidget);

      await tester.enterText(loginFields().at(1), 'wrong-again');
      await tester.pump();

      expect(find.text('Incorrect email or password.'), findsNothing);
    });

    testWidgets('Sign Up navigates to the registration screen', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets('Forgot Password pushes the reset screen with a back arrow', (
      tester,
    ) async {
      await openLogin(tester);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot your password?'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('lays out without overflow across viewport widths', (
      tester,
    ) async {
      for (final size in const [
        Size(320, 640),
        Size(360, 800),
        Size(412, 915),
        Size(1280, 900),
      ]) {
        await pumpPulseApp(tester, authenticated: false, size: size);
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });
  });

  group('routing', () {
    testWidgets(
      'an authenticated user visiting Login is redirected to Home',
      (tester) async {
        await pumpPulseApp(tester, initialLocation: AppRoutes.login);

        expect(find.text('Hi, Aarav'), findsOneWidget);
        expect(find.text('Welcome back'), findsNothing);
      },
    );

    testWidgets(
      'an unauthenticated visitor to a protected tab is redirected to Login',
      (tester) async {
        await pumpPulseApp(
          tester,
          authenticated: false,
          initialLocation: AppRoutes.cards,
        );

        expect(find.text('Welcome back'), findsOneWidget);
      },
    );
  });
}
