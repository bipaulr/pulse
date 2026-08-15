import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/persistence/app_preferences.dart';
import 'package:pulse/features/auth/data/auth_controller.dart';
import 'package:pulse/features/auth/data/auth_repository.dart';
import 'package:pulse/features/auth/data/auth_state.dart';
import 'package:pulse/features/auth/data/onboarding_controller.dart';

import 'support/in_memory_app_preferences.dart';

ProviderContainer _container({bool onboardingComplete = false, AuthSession? session}) {
  final container = ProviderContainer(
    overrides: [
      appPreferencesProvider.overrideWithValue(
        InMemoryAppPreferences(
          onboardingComplete: onboardingComplete,
          session: session,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('AuthController', () {
    test('starts unauthenticated when no session is persisted', () {
      final container = _container();
      expect(
        container.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
      expect(container.read(authControllerProvider).user, isNull);
    });

    test('restores an authenticated session on startup', () {
      final container = _container(
        session: const AuthSession(
          firstName: 'Aarav',
          lastName: 'Sharma',
          email: MockAuthRepository.demoEmail,
        ),
      );
      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.firstName, 'Aarav');
    });

    test('login with the demo credentials succeeds', () async {
      final container = _container();
      await container
          .read(authControllerProvider.notifier)
          .login(
            email: MockAuthRepository.demoEmail,
            password: MockAuthRepository.demoPassword,
          );

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.fullName, 'Aarav Sharma');
      // The session must actually be persisted, not just held in memory.
      expect(container.read(appPreferencesProvider).session?.email, isNotNull);
    });

    test('login with the wrong password fails and leaves an error', () async {
      final container = _container();
      await container
          .read(authControllerProvider.notifier)
          .login(email: MockAuthRepository.demoEmail, password: 'wrong-pass');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.errorMessage, isNotNull);
      expect(container.read(appPreferencesProvider).session, isNull);
    });

    test('login with an unknown email fails', () async {
      final container = _container();
      await container
          .read(authControllerProvider.notifier)
          .login(email: 'nobody@example.com', password: 'pulse1234');

      expect(
        container.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
    });

    test('sign-up with any well-formed details succeeds', () async {
      final container = _container();
      await container
          .read(authControllerProvider.notifier)
          .signUp(
            name: 'Jordan Lee',
            email: 'jordan@example.com',
            password: 'pulse1234',
          );

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.firstName, 'Jordan');
      expect(state.user?.lastName, 'Lee');
    });

    test('logout clears both state and the persisted session', () async {
      final container = _container(
        session: const AuthSession(
          firstName: 'Aarav',
          lastName: 'Sharma',
          email: MockAuthRepository.demoEmail,
        ),
      );
      expect(container.read(authControllerProvider).isAuthenticated, isTrue);

      await container.read(authControllerProvider.notifier).logout();

      expect(container.read(authControllerProvider).isAuthenticated, isFalse);
      expect(container.read(appPreferencesProvider).session, isNull);
    });

    test('dismissError clears a shown error without changing anything else',
        () async {
      final container = _container();
      await container
          .read(authControllerProvider.notifier)
          .login(email: MockAuthRepository.demoEmail, password: 'wrong');
      expect(container.read(authControllerProvider).errorMessage, isNotNull);

      container.read(authControllerProvider.notifier).dismissError();

      expect(container.read(authControllerProvider).errorMessage, isNull);
      expect(
        container.read(authControllerProvider).status,
        AuthStatus.unauthenticated,
      );
    });
  });

  group('OnboardingController', () {
    test('reflects whatever AppPreferences was seeded with', () {
      expect(
        _container(onboardingComplete: false).read(onboardingCompleteProvider),
        isFalse,
      );
      expect(
        _container(onboardingComplete: true).read(onboardingCompleteProvider),
        isTrue,
      );
    });

    test('complete() persists and flips the flag', () async {
      final container = _container();
      expect(container.read(onboardingCompleteProvider), isFalse);

      await container.read(onboardingCompleteProvider.notifier).complete();

      expect(container.read(onboardingCompleteProvider), isTrue);
      expect(container.read(appPreferencesProvider).onboardingComplete, isTrue);
    });
  });

  group('MockAuthRepository', () {
    test('requestPasswordReset always succeeds without throwing', () async {
      const repo = MockAuthRepository();
      await expectLater(
        repo.requestPasswordReset(email: 'anyone@example.com'),
        completes,
      );
    });
  });
}
