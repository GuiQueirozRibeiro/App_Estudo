import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../../../../common/widgets/image_input.dart';
import '../../../core/models/auth_form_data.dart';
import '../widget/auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleImagePick(File image) {
    _formData.image = image;
  }

  bool isValidEmail(String email) {
    RegExp emailRegExp = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+\=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');
    return emailRegExp.hasMatch(email);
  }

  bool isValidPassword(String password) {
    RegExp passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    Auth auth = Provider.of(context, listen: false);

    final errorMessage = await auth.signup(
      _formData.name,
      _formData.email,
      _formData.password,
      _formData.image!,
    );

    if (errorMessage != null) {
      _showErrorDialog(errorMessage);
    } else {
      Modular.to.navigate('/home/');
    }

    setState(() => _isLoading = false);
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
                      'sign_up_title'.i18n(),
                      style: TextStyle(
                        fontSize: screenSize.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ImageInput(_handleImagePick),
                          SizedBox(height: screenSize.height * 0.016),
                          Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: CustomTextField(
                              key: const ValueKey('name'),
                              initialValue: _formData.name,
                              onChanged: (name) => _formData.name = name!,
                              text: 'name_field'.i18n(),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (name) {
                                if (name!.isEmpty) {
                                  return 'name_required'.i18n();
                                }
                                if (name.trim().length < 5) {
                                  return 'name_invalid'.i18n();
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
                              key: const ValueKey('email'),
                              initialValue: _formData.email,
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
                              textInputAction: TextInputAction.next,
                              obscureText: true,
                              validator: (password) {
                                if (password!.isEmpty) {
                                  return 'password_required'.i18n();
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
                              onChanged: (password) =>
                                  _formData.password = password!,
                              text: 'confirm_password'.i18n(),
                              obscureText: true,
                              validator: (password) {
                                if (password != _formData.password) {
                                  return 'passwords_do_not_match'.i18n();
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _submit();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.outline,
                          )
                        : CustomButton(
                            size: screenSize,
                            onPressed: _submit,
                            buttonText: 'sign_in'.i18n(),
                          ),
                    SizedBox(height: screenSize.height * 0.08),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'with_account'.i18n(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                        CustomButton(
                          size: screenSize,
                          onPressed: () {
                            Modular.to.pop();
                          },
                          buttonText: 'login'.i18n(),
                          isBig: false,
                        ),
                      ],
                    ),
                    SizedBox(height: screenSize.height * 0.02),
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
