import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_dataset.dart';
import '../../../shared/models/models.dart';

/// Thrown by [AuthRepository] on a rejected attempt. The message is written
/// to be shown directly in the UI.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Source of truth for authentication.
///
/// This is a mock: there is no backend, no token, no password hashing. It
/// exists as a seam — swapping [authRepositoryProvider]'s binding for a
/// REST-backed implementation is the entire migration.
abstract interface class AuthRepository {
  Future<UserProfile> login({required String email, required String password});

  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> requestPasswordReset({required String email});
}

/// Accepts exactly one demo account, plus any freshly "signed up" one.
///
/// The short delay on every call stands in for a network round trip — long
/// enough that [AuthStatus.authenticating] is actually visible, short enough
/// not to feel like a stall.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  static const demoEmail = 'demo@pulse.app';
  static const demoPassword = 'pulse1234';

  static const _latency = Duration(milliseconds: 700);

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(_latency);

    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const AuthException('Incorrect email or password.');
    }

    // The demo account *is* Aarav Sharma — the same identity the rest of the
    // app's mock data already belongs to, so Home's greeting and the signed-in
    // user always agree.
    return MockDataset.user;
  }

  @override
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(_latency);

    final parts = name.trim().split(RegExp(r'\s+'));
    return UserProfile(
      firstName: parts.first,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    await Future.delayed(_latency);
    // A mock: nothing is sent. The caller always sees the same neutral
    // confirmation, whether or not the email is real — the standard, safer
    // pattern that doesn't reveal which addresses have accounts.
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => const MockAuthRepository(),
);
