import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/pulse_theme.dart';

/// Root of the Pulse app.
///
/// `themeMode` is pinned to light for now; wiring a dark palette later means
/// adding `darkTheme` here and a `PulseColors.dark` — no widget changes.
class PulseApp extends ConsumerWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: PulseTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
