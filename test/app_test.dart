import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/app.dart';
import 'package:pulse/core/routing/app_shell.dart';

void main() {
  testWidgets('boots into Home with the Pulse navigation bar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PulseApp()));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches tabs through the bottom navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PulseApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.credit_card_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Cards'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.pie_chart_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Activity'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
