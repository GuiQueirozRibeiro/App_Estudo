import 'package:localization/localization.dart';

class AuthException implements Exception {
  static Map<String, String> errors = {
    'EMAIL_EXISTS': 'email_exists'.i18n(),
    'OPERATION_NOT_ALLOWED': 'operation_not_allowed!'.i18n(),
    'TOO_MANY_ATTEMPTS_TRY_LATER': 'too_many_attemps'.i18n(),
    'EMAIL_NOT_FOUND': 'email_not_found'.i18n(),
    'INVALID_PASSWORD': 'invalid_password'.i18n(),
    'USER_DISABLED': 'user_disabled'.i18n(),
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key] ?? 'authentication_error'.i18n();
  }
}
