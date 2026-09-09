import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/pulse_theme.dart';
import 'core/theme/theme_mode_controller.dart';

/// Root of the Pulse app.
///
/// `themeMode` follows [themeModeControllerProvider], which defaults to
/// [ThemeMode.system] and persists an explicit override via
/// [AppPreferences].
class PulseApp extends ConsumerWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: PulseTheme.light,
      darkTheme: PulseTheme.dark,
      themeMode: ref.watch(themeModeControllerProvider),
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
