import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse/app.dart';
import 'package:pulse/features/home/data/home_repository.dart';
import 'package:pulse/features/transactions/data/transactions_repository.dart';

/// A clock the mock data is pinned to, so relative timestamps are stable.
final testNow = DateTime(2026, 8, 13, 15, 30);

/// Pulse is a phone app, so tests run on a phone-shaped surface rather than
/// the 800x600 default — on which the aspect-ratio'd cards would be enormous.
const phoneSize = Size(390, 844);

/// Boots the real app with the mock data pinned to [testNow], optionally
/// starting on a route other than Home.
Future<void> pumpPulseApp(
  WidgetTester tester, {
  String? initialLocation,
  Size size = phoneSize,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeRepositoryProvider.overrideWithValue(
          MockHomeRepository(now: testNow),
        ),
        transactionsRepositoryProvider.overrideWithValue(
          MockTransactionsRepository(now: testNow),
        ),
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
