import 'package:flutter/foundation.dart';

import '../../../shared/models/models.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated }

/// Centralized auth state — the single thing every screen reads instead of a
/// scattered `isLoggedIn` boolean.
@immutable
class AuthState {
  const AuthState._({required this.status, this.user, this.errorMessage});

  const AuthState.unauthenticated({String? errorMessage})
    : this._(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  const AuthState.authenticating()
    : this._(status: AuthStatus.authenticating);

  const AuthState.authenticated(UserProfile user)
    : this._(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;

  /// Set only when [status] is [AuthStatus.authenticated].
  final UserProfile? user;

  /// Set only right after a failed attempt, so Login can show it once.
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}
