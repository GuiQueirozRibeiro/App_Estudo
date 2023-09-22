import 'package:firebase_auth/firebase_auth.dart';
import 'package:localization/localization.dart';

class AuthException implements Exception {
  static Map<String, String> errors = {
    'user-disabled': 'user_disabled',
    'user-not-found': 'user_not_found',
    'wrong-password': 'invalid_password',
  };

  final String code;

  AuthException(this.code);

  @override
  String toString() {
    if (errors.containsKey(code)) {
      return errors[code]!.i18n();
    } else {
      return code;
    }
  }

  static AuthException fromFirebaseAuthException(FirebaseAuthException e) {
    return AuthException(e.code);
  }
}
