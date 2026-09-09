import 'package:pulse/core/persistence/app_preferences.dart';

/// A test-only [AppPreferences] with no plugin channel involved — nothing
/// beyond a couple of fields in memory, seeded directly by the test.
class InMemoryAppPreferences implements AppPreferences {
  InMemoryAppPreferences({
    bool onboardingComplete = true,
    AuthSession? session,
    AppThemeMode themeMode = AppThemeMode.system,
    Set<String> frozenCardIds = const {},
  }) : _onboardingComplete = onboardingComplete,
       _session = session,
       _themeMode = themeMode,
       _frozenCardIds = frozenCardIds;

  bool _onboardingComplete;
  AuthSession? _session;
  AppThemeMode _themeMode;
  Set<String> _frozenCardIds;

  @override
  bool get onboardingComplete => _onboardingComplete;

  @override
  Future<void> setOnboardingComplete(bool value) async {
    _onboardingComplete = value;
  }

  @override
  AuthSession? get session => _session;

  @override
  Future<void> saveSession(AuthSession session) async {
    _session = session;
  }

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  AppThemeMode get themeMode => _themeMode;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
  }

  @override
  Set<String> get frozenCardIds => _frozenCardIds;

  @override
  Future<void> setFrozenCardIds(Set<String> ids) async {
    _frozenCardIds = ids;
  }
}
