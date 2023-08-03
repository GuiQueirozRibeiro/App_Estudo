import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/exceptions/auth_exception.dart';
import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEmailSent = false;

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

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    final FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.sendPasswordResetEmail(
        email: _emailController.text,
      );

      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });

      _showSuccessDialog();
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
      setState(() => _isLoading = false);
    } catch (error) {
      _showErrorDialog('unexpected_error'.i18n());
      setState(() => _isLoading = false);
    }
  }

  bool isValidEmail(String email) {
    RegExp emailRegExp = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+\=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');
    return emailRegExp.hasMatch(email);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.1,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Image.asset(
                      'lib/assets/images/snap_icon.png',
                      height: screenSize.height * 0.2,
                    ),
                    Text(
                      'reset_password'.i18n(),
                      style: TextStyle(
                        fontSize: screenSize.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.height * 0.06),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomTextField(
                            text: 'email_field'.i18n(),
                            isForm: false,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (email) {
                              if (email!.isEmpty) {
                                return 'email_required'.i18n();
                              } else if (!isValidEmail(email)) {
                                return 'email_invalid'.i18n();
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _submit();
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.06),
                    _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.outline,
                          )
                        : CustomButton(
                            size: screenSize,
                            onPressed:
                                _isEmailSent ? _showSuccessDialog : _submit,
                            buttonText: 'send'.i18n(),
                          ),
                    SizedBox(height: screenSize.height * 0.12),
                    CustomButton(
                      size: screenSize,
                      onPressed: (() => Modular.to.pop()),
                      buttonText: 'back'.i18n(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
