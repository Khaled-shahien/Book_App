import 'package:book_app/core/auth/auth_error_mapper.dart';
import 'package:book_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty and malformed', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('  '), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a b@c.com'), isNotNull);
    });
    test('accepts valid (trimmed)', () {
      expect(Validators.email(' user@example.com '), isNull);
    });
  });

  group('Validators.newPassword', () {
    test('enforces length and letters+digits', () {
      expect(Validators.newPassword(''), isNotNull);
      expect(Validators.newPassword('abc123'), isNotNull);
      expect(Validators.newPassword('abcdefgh'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull);
      expect(Validators.newPassword('abcd1234'), isNull);
    });
  });

  test('loginPassword only requires presence', () {
    expect(Validators.loginPassword(''), isNotNull);
    expect(Validators.loginPassword('x'), isNull);
  });

  test('confirmPassword must match', () {
    expect(Validators.confirmPassword('a', 'b'), isNotNull);
    expect(Validators.confirmPassword('', ''), isNotNull);
    expect(Validators.confirmPassword('abc', 'abc'), isNull);
  });

  test('username bounds', () {
    expect(Validators.username(' '), isNotNull);
    expect(Validators.username('a'), isNotNull);
    expect(Validators.username('a' * 41), isNotNull);
    expect(Validators.username('Khaled'), isNull);
  });

  group('AuthErrorMapper', () {
    test('does not reveal whether an account exists', () {
      for (final code in [
        'user-not-found',
        'wrong-password',
        'invalid-credential',
      ]) {
        expect(
          AuthErrorMapper.message(code),
          AuthErrorMapper.invalidCredentials,
        );
      }
    });
    test('maps known codes and falls back for unknown ones', () {
      expect(
        AuthErrorMapper.message('too-many-requests'),
        contains('Too many'),
      );
      expect(
        AuthErrorMapper.message('network-request-failed'),
        contains('internet'),
      );
      expect(AuthErrorMapper.message('???'), contains('Something went wrong'));
    });
  });
}
