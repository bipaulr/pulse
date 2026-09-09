import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The persisted theme preference. Kept independent of Flutter's own
/// `ThemeMode` so this layer has no widgets dependency — [PulseApp] maps it
/// to `ThemeMode` at the one place that actually needs it.
enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromName(String? name) => AppThemeMode.values
      .firstWhere((mode) => mode.name == name, orElse: () => AppThemeMode.system);
}

/// The minimum session snapshot needed to restore a "logged in" state across
/// restarts. Never a password — only what the UI needs to greet the user.
@immutable
class AuthSession {
  const AuthSession({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String email;
}

/// The tiny slice of local state Pulse persists: whether onboarding has been
/// seen, and the mock session (if any).
///
/// Reads are synchronous — [SharedPreferences.getInstance] is awaited once in
/// `main()` before the app is built, so every provider downstream of that can
/// read this without its own async gap. This is deliberately the entire
/// persistence layer; nothing else in the app is stored locally.
abstract interface class AppPreferences {
  bool get onboardingComplete;
  Future<void> setOnboardingComplete(bool value);

  AuthSession? get session;
  Future<void> saveSession(AuthSession session);
  Future<void> clearSession();

  AppThemeMode get themeMode;
  Future<void> setThemeMode(AppThemeMode mode);

  /// Ids of cards the user has frozen — survives an app restart, unlike the
  /// in-memory-only state this used to be.
  Set<String> get frozenCardIds;
  Future<void> setFrozenCardIds(Set<String> ids);
}

class SharedPreferencesAppPreferences implements AppPreferences {
  SharedPreferencesAppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingKey = 'pulse.onboarding_complete';
  static const _firstNameKey = 'pulse.session.first_name';
  static const _lastNameKey = 'pulse.session.last_name';
  static const _emailKey = 'pulse.session.email';
  static const _themeModeKey = 'pulse.theme_mode';
  static const _frozenCardIdsKey = 'pulse.frozen_card_ids';

  @override
  bool get onboardingComplete => _prefs.getBool(_onboardingKey) ?? false;

  @override
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_onboardingKey, value);

  @override
  AuthSession? get session {
    final email = _prefs.getString(_emailKey);
    if (email == null) return null;
    return AuthSession(
      firstName: _prefs.getString(_firstNameKey) ?? '',
      lastName: _prefs.getString(_lastNameKey) ?? '',
      email: email,
    );
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _prefs.setString(_firstNameKey, session.firstName);
    await _prefs.setString(_lastNameKey, session.lastName);
    await _prefs.setString(_emailKey, session.email);
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_firstNameKey);
    await _prefs.remove(_lastNameKey);
    await _prefs.remove(_emailKey);
  }

  @override
  AppThemeMode get themeMode => AppThemeMode.fromName(_prefs.getString(_themeModeKey));

  @override
  Future<void> setThemeMode(AppThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  @override
  Set<String> get frozenCardIds =>
      (_prefs.getStringList(_frozenCardIdsKey) ?? const []).toSet();

  @override
  Future<void> setFrozenCardIds(Set<String> ids) =>
      _prefs.setStringList(_frozenCardIdsKey, ids.toList(growable: false));
}

/// Must be overridden — in `main()` with a [SharedPreferencesAppPreferences]
/// once the device store has loaded, or in tests with an in-memory fake.
/// Failing loudly here beats silently losing "logged in" state.
final appPreferencesProvider = Provider<AppPreferences>(
  (ref) => throw UnimplementedError(
    'appPreferencesProvider must be overridden before the app is built',
  ),
);
