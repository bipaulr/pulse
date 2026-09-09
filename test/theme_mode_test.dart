import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/persistence/app_preferences.dart';
import 'package:pulse/core/theme/theme_mode_controller.dart';

import 'support/in_memory_app_preferences.dart';
import 'support/pump_app.dart';

void main() {
  group('ThemeModeController', () {
    test('defaults to system when nothing has been saved', () {
      final container = ProviderContainer(
        overrides: [
          appPreferencesProvider.overrideWithValue(InMemoryAppPreferences()),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeModeControllerProvider), ThemeMode.system);
    });

    test('setThemeMode persists across a simulated app restart', () async {
      final store = InMemoryAppPreferences();

      final firstRun = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(store)],
      );
      await firstRun
          .read(themeModeControllerProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      expect(firstRun.read(themeModeControllerProvider), ThemeMode.dark);
      firstRun.dispose();

      final secondRun = ProviderContainer(
        overrides: [appPreferencesProvider.overrideWithValue(store)],
      );
      addTearDown(secondRun.dispose);

      expect(secondRun.read(themeModeControllerProvider), ThemeMode.dark);
    });
  });

  group('Appearance toggle', () {
    testWidgets('switching to Dark in the profile sheet re-themes the app', (
      tester,
    ) async {
      await pumpPulseApp(tester);

      await tester.tap(find.text('AS'));
      await tester.pumpAndSettle();

      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
    });
  });
}
