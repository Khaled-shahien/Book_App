/// Maps Firebase Auth error codes to user-presentable messages.
///
/// Sign-in errors intentionally share one message for wrong email/password so
/// the app does not reveal which accounts exist (account enumeration).
abstract final class AuthErrorMapper {
  static const invalidCredentials = 'Incorrect email or password.';

  static String message(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'user-not-found':
      case 'wrong-password':
        return invalidCredentials;
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'requires-recent-login':
        return 'Please sign in again to continue.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
