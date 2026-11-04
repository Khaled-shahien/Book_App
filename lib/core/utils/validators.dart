/// Pure form validators shared by the auth screens (unit-tested).
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    if (v.length > 254 || !_email.hasMatch(v)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Sign-in: only require presence; the server decides validity.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  /// Sign-up: at least 8 characters with a letter and a digit.
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Please enter your password';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (v.length > 128) return 'Password is too long';
    if (!RegExp('[A-Za-z]').hasMatch(v) || !RegExp('[0-9]').hasMatch(v)) {
      return 'Use letters and numbers';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your username';
    if (v.length < 2) return 'Username is too short';
    if (v.length > 40) return 'Username must be 40 characters or fewer';
    return null;
  }
}
