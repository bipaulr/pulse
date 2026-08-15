/// Pure client-side validation for the auth forms.
///
/// Each function returns the error message to show, or `null` when the value
/// is acceptable — the shape `PulseTextField.errorText` expects directly, and
/// trivial to unit test without pumping a widget.
abstract final class AuthValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static const minPasswordLength = 8;

  static String? name(String value) {
    if (value.trim().isEmpty) return 'Enter your name.';
    return null;
  }

  static String? email(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Enter your email.';
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Enter your password.';
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters.';
    }
    return null;
  }

  /// Signup's confirm-password field: needs the original value alongside it.
  static String? confirmPassword(String password, String confirmation) {
    if (confirmation.isEmpty) return 'Confirm your password.';
    if (confirmation != password) return 'Passwords do not match.';
    return null;
  }
}
