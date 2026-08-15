import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/app_preferences.dart';
import '../../../shared/models/models.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

/// Owns [AuthState] for the whole app.
///
/// Restores a persisted mock session synchronously on startup — see
/// [AppPreferences] for why that read never blocks — so Splash can decide
/// where to go without an extra loading frame.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final session = ref.watch(appPreferencesProvider).session;
    if (session == null) return const AuthState.unauthenticated();
    return AuthState.authenticated(
      UserProfile(firstName: session.firstName, lastName: session.lastName),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.authenticating();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await _persistAndSetAuthenticated(user, email);
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthState.authenticating();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(name: name, email: email, password: password);
      await _persistAndSetAuthenticated(user, email);
    } on AuthException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
    }
  }

  Future<void> _persistAndSetAuthenticated(
    UserProfile user,
    String email,
  ) async {
    await ref
        .read(appPreferencesProvider)
        .saveSession(
          AuthSession(
            firstName: user.firstName,
            lastName: user.lastName,
            email: email.trim().toLowerCase(),
          ),
        );
    state = AuthState.authenticated(user);
  }

  Future<void> logout() async {
    await ref.read(appPreferencesProvider).clearSession();
    state = const AuthState.unauthenticated();
  }

  /// Clears a shown error without otherwise touching the state — called once
  /// the field that caused it changes, so a stale message doesn't linger.
  void dismissError() {
    if (state.errorMessage == null) return;
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
