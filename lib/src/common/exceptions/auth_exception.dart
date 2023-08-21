import 'package:firebase_auth/firebase_auth.dart';
import 'package:localization/localization.dart';

class AuthException implements Exception {
  static Map<String, String> errors = {
    'invalid-email': 'email_not_found'.i18n(),
    'user_disabled': 'user_disabled'.i18n(),
    'user-not-found': 'user-not-found'.i18n(),
    'wrong-password': 'invalid_password'.i18n(),
  };

  final String code;

  AuthException(this.code);

  @override
  String toString() {
    return code.toString();
  }

  static AuthException fromFirebaseAuthException(FirebaseAuthException e) {
    return AuthException(e.code);
  }
}
