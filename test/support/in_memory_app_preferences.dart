import 'package:pulse/core/persistence/app_preferences.dart';

/// A test-only [AppPreferences] with no plugin channel involved — nothing
/// beyond a couple of fields in memory, seeded directly by the test.
class InMemoryAppPreferences implements AppPreferences {
  InMemoryAppPreferences({
    bool onboardingComplete = true,
    AuthSession? session,
  }) : _onboardingComplete = onboardingComplete,
       _session = session;

  bool _onboardingComplete;
  AuthSession? _session;

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
}
