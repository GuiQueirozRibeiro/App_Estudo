import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../../repository/auth_form_data.dart';
import '../../viewmodel/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    AuthViewModel authViewModel = Provider.of(context, listen: false);

    await authViewModel.login(
      _formData.email,
      _formData.password,
    );
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'lib/assets/images/logo.png',
                      height: screenSize.height * 0.1,
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      'login_title'.i18n(),
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
                          Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: CustomTextField(
                              key: const ValueKey('email'),
                              initialValue: _formData.email,
                              onChanged: (email) => _formData.email = email!,
                              text: 'email_field'.i18n(),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (email) {
                                if (email!.isEmpty) {
                                  return 'email_required'.i18n();
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.016),
                          Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: CustomTextField(
                              valueKey: const ValueKey('password'),
                              initialValue: _formData.password,
                              onChanged: (password) =>
                                  _formData.password = password!,
                              text: 'password_field'.i18n(),
                              obscureText: true,
                              validator: (password) {
                                if (password!.isEmpty) {
                                  return 'password_required'.i18n();
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _submit();
                              },
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.008),
                          TextButton(
                            onPressed: () {
                              Modular.to.pushNamed('forgotPassword');
                            },
                            style: const ButtonStyle(
                              alignment: Alignment.centerRight,
                            ),
                            child: Text(
                              'forgot_password'.i18n(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: screenSize.width * 0.04,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    Consumer<AuthViewModel>(
                      builder: (context, authViewModel, child) {
                        return authViewModel.isLoading
                            ? CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.outline,
                              )
                            : CustomButton(
                                size: screenSize,
                                onPressed: _submit,
                                buttonText: 'login'.i18n(),
                              );
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'without_account'.i18n(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                        CustomButton(
                          size: screenSize,
                          buttonText: 'sign_up'.i18n(),
                          onPressed: () {
                            Modular.to.pushNamed('signup');
                          },
                          isBig: false,
                        ),
                      ],
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
