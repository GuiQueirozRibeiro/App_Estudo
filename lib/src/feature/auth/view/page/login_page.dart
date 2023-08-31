import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../common/widgets/custom_button.dart';
import '../../../../common/widgets/custom_text_field.dart';
import '../../repository/auth_form_data.dart';
import '../../viewmodel/auth_view_model.dart';

class LoginPage extends StatefulWidget {
  final bool isStudant;
  const LoginPage({
    this.isStudant = true,
    Key? key,
  }) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    AuthViewModel authViewModel =
        Provider.of<AuthViewModel>(context, listen: false);

    final errorMessage = await authViewModel.login(
      widget.isStudant
          ? _formData.id + _formData.emailSt
          : _formData.id + _formData.emailTc,
      _formData.password,
    );

    if (errorMessage != null) {
      _showErrorDialog(errorMessage);
    } else {
      Modular.to.navigate('/home/');
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
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
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    widget.isStudant
                        ? 'student_title'.i18n()
                        : 'teacher_title'.i18n(),
                    style: TextStyle(
                      fontSize: screenSize.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
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
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: CustomTextField(
                            key: const ValueKey('id'),
                            initialValue: _formData.id,
                            onChanged: (id) => _formData.id = id!,
                            text: widget.isStudant
                                ? 'student_field'.i18n()
                                : 'teacher_field'.i18n(),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (id) {
                              if (id!.isEmpty) {
                                return widget.isStudant
                                    ? 'student_required'.i18n()
                                    : 'teacher_required'.i18n();
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.016),
                        Card(
                          elevation: 4,
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
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return authViewModel.isLoading
                          ? CircularProgressIndicator(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            )
                          : CustomButton(
                              isBig: true,
                              size: screenSize,
                              onPressed: _submit,
                              buttonText: 'login'.i18n(),
                            );
                    },
                  ),
                  SizedBox(height: screenSize.height * 0.12),
                  CustomButton(
                    isBig: true,
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
    );
  }
}
