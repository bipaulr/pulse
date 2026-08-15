import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/auth/data/auth_validators.dart';

void main() {
  group('name', () {
    test('rejects empty and whitespace-only input', () {
      expect(AuthValidators.name(''), isNotNull);
      expect(AuthValidators.name('   '), isNotNull);
    });

    test('accepts a real name', () {
      expect(AuthValidators.name('Aarav Sharma'), isNull);
    });
  });

  group('email', () {
    test('rejects empty input', () {
      expect(AuthValidators.email(''), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(AuthValidators.email('not-an-email'), isNotNull);
      expect(AuthValidators.email('missing@domain'), isNotNull);
      expect(AuthValidators.email('@missinglocal.com'), isNotNull);
      expect(AuthValidators.email('spaces in@email.com'), isNotNull);
    });

    test('accepts well-formed addresses', () {
      expect(AuthValidators.email('demo@pulse.app'), isNull);
      expect(AuthValidators.email('  demo@pulse.app  '), isNull);
      expect(AuthValidators.email('a.b+c@sub.example.co'), isNull);
    });
  });

  group('password', () {
    test('rejects empty input', () {
      expect(AuthValidators.password(''), isNotNull);
    });

    test('rejects passwords shorter than the minimum', () {
      expect(AuthValidators.password('short'), isNotNull);
      expect(
        AuthValidators.password(
          'x' * (AuthValidators.minPasswordLength - 1),
        ),
        isNotNull,
      );
    });

    test('accepts a password at or above the minimum length', () {
      expect(
        AuthValidators.password('x' * AuthValidators.minPasswordLength),
        isNull,
      );
      expect(AuthValidators.password('pulse1234'), isNull);
    });
  });

  group('confirmPassword', () {
    test('rejects an empty confirmation', () {
      expect(AuthValidators.confirmPassword('pulse1234', ''), isNotNull);
    });

    test('rejects a mismatch', () {
      expect(
        AuthValidators.confirmPassword('pulse1234', 'pulse4321'),
        isNotNull,
      );
    });

    test('accepts a match', () {
      expect(AuthValidators.confirmPassword('pulse1234', 'pulse1234'), isNull);
    });
  });
}
