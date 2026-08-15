import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/routing/app_routes.dart';

import 'support/pump_app.dart';

Future<void> _loadFonts() async {
  const candidates = {
    'Roboto': r'C:\Windows\Fonts\segoeui.ttf',
    'Roboto-Bold': r'C:\Windows\Fonts\segoeuib.ttf',
    'MaterialIcons':
        r'C:\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
  };
  for (final entry in candidates.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  const routes = {
    'home': AppRoutes.home,
    'cards': AppRoutes.cards,
    'txns': AppRoutes.transactions,
    'activity': AppRoutes.activity,
  };

  const sizes = {
    '320': Size(320, 640),
    '360': Size(360, 800),
    '390': Size(390, 844),
    '412': Size(412, 915),
    'desktop': Size(1280, 900),
  };

  for (final routeEntry in routes.entries) {
    for (final sizeEntry in sizes.entries) {
      testWidgets('${routeEntry.key} @ ${sizeEntry.key} no overflow', (
        tester,
      ) async {
        await pumpPulseApp(
          tester,
          initialLocation: routeEntry.value,
          size: sizeEntry.value,
        );
        expect(tester.takeException(), isNull);

        // Scroll to the end to catch overflow further down the page too.
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          await tester.drag(scrollables.first, const Offset(0, -2000));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'every tab shares the same desktop width constraint, not just Activity',
    (tester) async {
      for (final route in routes.values) {
        await pumpPulseApp(
          tester,
          initialLocation: route,
          size: const Size(1280, 900),
        );
        // PulseBottomNavigation's own wrapper spans the full width so its
        // Center can position the pill — the pill itself is the ConstrainedBox
        // it declares, which is what must stay narrow.
        final pillWidth = tester
            .getSize(
              find
                  .descendant(
                    of: find.byWidgetPredicate(
                      (w) =>
                          w.runtimeType.toString() == 'PulseBottomNavigation',
                    ),
                    matching: find.byType(ConstrainedBox),
                  )
                  .first,
            )
            .width;
        expect(pillWidth, lessThan(600), reason: 'route: $route');
      }
    },
  );
}
