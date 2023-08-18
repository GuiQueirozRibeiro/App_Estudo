import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';

import '../../../common/exceptions/auth_exception.dart';
import '../usecase/auth_use_case.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthUseCase _authUseCase;
  final BuildContext context;

  AuthViewModel(this._authUseCase, this.context);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> signup(
      String name, String email, String password, File image) async {
    try {
      _isLoading = true;
      notifyListeners();

      final errorMessage =
          await _authUseCase.signup(name, email, password, image);

      if (errorMessage != null) {
        _showErrorDialog(errorMessage);
      } else {
        Modular.to.navigate('/home/');
      }
    } on AuthException catch (error) {
      _handleAuthException(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final errorMessage = await _authUseCase.login(email, password);

      if (errorMessage != null) {
        _showErrorDialog(errorMessage);
      } else {
        Modular.to.navigate('/home/');
      }
    } on AuthException catch (error) {
      _handleAuthException(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      final errorMessage = await _authUseCase.resetPassword(email);

      if (errorMessage != null) {
        _showErrorDialog(errorMessage);
      } else {
        _showSuccessDialog();
      }
    } on AuthException catch (error) {
      _handleAuthException(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('error_occurred'.i18n()),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('close'.i18n()),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('success_email_send'.i18n()),
        content: Text('forgot_password_mensage'.i18n()),
        actions: [
          ElevatedButton(
            child: Text('ok'.i18n()),
            onPressed: () {
              Navigator.of(context).pop();
              Modular.to.pop();
            },
          ),
        ],
      ),
    );
  }

  void _handleAuthException(AuthException error) {
    final errorMessage = AuthException.errors[error.code];
    if (errorMessage != null) {
      _showErrorDialog(errorMessage);
    } else {
      _showErrorDialog('generic_error_message'.i18n());
    }
  }
}
