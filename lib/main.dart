import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/persistence/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Awaited once, here — every provider downstream reads AppPreferences
  // synchronously, so Splash never has to show an extra loading frame just to
  // find out whether a session exists.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(
          SharedPreferencesAppPreferences(prefs),
        ),
      ],
      child: const PulseApp(),
    ),
  );
}
