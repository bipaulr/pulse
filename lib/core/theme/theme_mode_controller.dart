import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/app_preferences.dart';

/// Owns the app's [ThemeMode], persisted via [AppPreferences].
///
/// Stored as [AppThemeMode] (a plain enum with no Flutter dependency) and
/// mapped to [ThemeMode] here — the one place that actually needs it.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() =>
      _toThemeMode(ref.watch(appPreferencesProvider).themeMode);

  Future<void> setThemeMode(ThemeMode mode) async {
    final appThemeMode = switch (mode) {
      ThemeMode.system => AppThemeMode.system,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.dark => AppThemeMode.dark,
    };
    await ref.read(appPreferencesProvider).setThemeMode(appThemeMode);
    state = mode;
  }

  static ThemeMode _toThemeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
