import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';
import 'package:pulse/features/auth/data/auth_validators.dart';

import 'support/pump_app.dart';

/// Name, email, password, confirm — in the order they appear on screen.
Finder signUpFields() => find.byType(TextField);

void main() {
  Future<void> openSignUp(WidgetTester tester) => pumpPulseApp(
    tester,
    authenticated: false,
    initialLocation: AppRoutes.signUp,
  );

  group('Sign Up', () {
    testWidgets('renders the form', (tester) async {
      await openSignUp(tester);

      expect(find.text('Create your account'), findsOneWidget);
      expect(signUpFields(), findsNWidgets(4));
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('shows every field\'s error after an empty submit', (
      tester,
    ) async {
      await openSignUp(tester);

      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your name.'), findsOneWidget);
      expect(find.text('Enter your email.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      expect(find.text('Confirm your password.'), findsOneWidget);
    });

    testWidgets('rejects a malformed email', (tester) async {
      await openSignUp(tester);

      await tester.enterText(signUpFields().at(0), 'Jordan Lee');
      await tester.enterText(signUpFields().at(1), 'not-an-email');
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
    });

    testWidgets('flags a password below the minimum length', (tester) async {
      await openSignUp(tester);

      await tester.enterText(signUpFields().at(2), 'short');
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Password must be at least '
          '${AuthValidators.minPasswordLength} characters.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('flags a confirmation that does not match', (tester) async {
      await openSignUp(tester);

      await tester.enterText(signUpFields().at(2), 'pulse1234');
      await tester.enterText(signUpFields().at(3), 'pulse4321');
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });

    testWidgets('valid details register and reach Home', (tester) async {
      await openSignUp(tester);

      await tester.enterText(signUpFields().at(0), 'Jordan Lee');
      await tester.enterText(signUpFields().at(1), 'jordan@example.com');
      await tester.enterText(signUpFields().at(2), 'pulse1234');
      await tester.enterText(signUpFields().at(3), 'pulse1234');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pumpAndSettle();

      // The freshly "created" name reaches Home's greeting, not the mock
      // dataset's default identity.
      expect(find.text('Hi, Jordan'), findsOneWidget);
    });

    testWidgets('Log In returns to the sign-in screen', (tester) async {
      await openSignUp(tester);

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('the back arrow also returns to Login', (tester) async {
      await openSignUp(tester);

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
        await pumpPulseApp(
          tester,
          authenticated: false,
          initialLocation: AppRoutes.signUp,
          size: size,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });
  });
}
