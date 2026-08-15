import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';

import 'support/pump_app.dart';

void main() {
  Future<void> openForgotPassword(WidgetTester tester, {Size? size}) =>
      pumpPulseApp(
        tester,
        authenticated: false,
        initialLocation: AppRoutes.forgotPassword,
        size: size ?? phoneSize,
      );

  group('Forgot Password', () {
    testWidgets('renders the form', (tester) async {
      await openForgotPassword(tester);

      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('rejects an invalid email before sending anything', (
      tester,
    ) async {
      await openForgotPassword(tester);

      await tester.enterText(find.byType(TextField), 'not-an-email');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets(
      'a valid email shows the neutral confirmation state',
      (tester) async {
        await openForgotPassword(tester);

        await tester.enterText(find.byType(TextField), 'demo@pulse.app');
        await tester.tap(find.text('Send Reset Link'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text('Check your email'), findsOneWidget);
        expect(
          find.text(
            'If an account exists for this email, a reset link has '
            'been sent.',
          ),
          findsOneWidget,
        );
        // The form itself is gone — only the confirmation remains.
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets('shows the same confirmation for an unknown email', (
      tester,
    ) async {
      // A mock reset never reveals whether the address has an account.
      await openForgotPassword(tester);

      await tester.enterText(find.byType(TextField), 'nobody@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Check your email'), findsOneWidget);
    });

    testWidgets('Back to Login from the confirmation returns to Login', (
      tester,
    ) async {
      await openForgotPassword(tester);
      await tester.enterText(find.byType(TextField), 'demo@pulse.app');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('the top back arrow returns to Login directly', (
      tester,
    ) async {
      await openForgotPassword(tester);

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
        await openForgotPassword(tester, size: size);
        expect(
          tester.takeException(),
          isNull,
          reason: 'overflowed at ${size.width}x${size.height}',
        );
      }
    });
  });
}
