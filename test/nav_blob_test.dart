import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/pump_app.dart';

/// The blob's current rect, read directly off its `Positioned` rather than
/// asserted from a screenshot — a precise, screenshot-independent way to
/// confirm it's actually mid-flight and not just teleporting.
Rect blobRect(WidgetTester tester) {
  final positioned = tester.widget<Positioned>(
    find.descendant(
      of: find.byWidgetPredicate((w) => w.runtimeType.toString() == '_NavBlob'),
      matching: find.byType(Positioned),
    ),
  );
  return Rect.fromLTWH(positioned.left!, 0, positioned.width!, positioned.height!);
}

void main() {
  group('Bottom navigation blob', () {
    testWidgets('sits under the selected destination on first render', (
      tester,
    ) async {
      await pumpPulseApp(tester);

      // Home is index 0 — the blob should already be resting at the left
      // edge of the bar before any interaction happens.
      final rect = blobRect(tester);
      expect(rect.left, lessThan(20));
    });

    testWidgets('follows the selected tab across all four destinations', (
      tester,
    ) async {
      await pumpPulseApp(tester);
      final atHome = blobRect(tester);

      for (final icon in [
        Icons.credit_card_rounded,
        Icons.swap_horiz_rounded,
        Icons.pie_chart_rounded,
      ]) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();
        final rect = blobRect(tester);
        expect(rect.left, greaterThan(atHome.left), reason: '$icon');
      }

      // Back to Home settles at the same resting position it started at.
      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();
      final backAtHome = blobRect(tester);
      expect(backAtHome.left, closeTo(atHome.left, 0.5));
      expect(backAtHome.width, closeTo(atHome.width, 0.5));
    });

    testWidgets('stretches wider mid-flight, then settles back down', (
      tester,
    ) async {
      await pumpPulseApp(tester);
      final settledOnHome = blobRect(tester);

      await tester.tap(find.byIcon(Icons.pie_chart_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 140));
      final midFlight = blobRect(tester);

      // Genuinely travelling (not a jump-cut) and visibly wider than its
      // resting size — the stretch that makes it read as a soft blob rather
      // than a rectangle sliding.
      expect(midFlight.left, greaterThan(settledOnHome.left));
      expect(midFlight.width, greaterThan(settledOnHome.width));

      await tester.pumpAndSettle();
      final settledOnActivity = blobRect(tester);
      expect(settledOnActivity.width, lessThan(midFlight.width));
      expect(settledOnActivity.left, greaterThan(midFlight.left));
      // And it comes to rest at the same width it started at — the stretch
      // is transient, not a permanent size change.
      expect(settledOnActivity.width, closeTo(settledOnHome.width, 0.5));
    });

    testWidgets('redirecting mid-transition does not snap backwards first', (
      tester,
    ) async {
      await pumpPulseApp(tester);

      // Tap Cards, then immediately Activity before the first transition
      // finishes — the second transition should continue from wherever the
      // blob actually is, not reset to Home.
      await tester.tap(find.byIcon(Icons.credit_card_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final midFirstFlight = blobRect(tester);

      await tester.tap(find.byIcon(Icons.pie_chart_rounded));
      await tester.pump();
      final redirected = blobRect(tester);

      expect(redirected.left, greaterThanOrEqualTo(midFirstFlight.left - 1));
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without overflow at the narrowest supported width', (
      tester,
    ) async {
      await pumpPulseApp(tester, size: const Size(320, 640));

      for (final icon in [
        Icons.credit_card_rounded,
        Icons.swap_horiz_rounded,
        Icons.pie_chart_rounded,
        Icons.grid_view_rounded,
      ]) {
        await tester.tap(find.byIcon(icon));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$icon');
      }
    });
  });
}
