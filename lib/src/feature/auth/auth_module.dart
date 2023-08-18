import 'package:flutter_modular/flutter_modular.dart';

import 'view/page/forgot_password_page.dart';
import 'view/page/signup_page.dart';
import 'view/page/login_page.dart';
import '../home/home_module.dart';

class AuthModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (_) => const LoginPage());
    r.child(
      '/signup',
      child: (_) => const SignupPage(),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/forgotPassword',
      child: (_) => const ForgotPasswordPage(),
      transition: TransitionType.fadeIn,
    );
    r.module('/home', module: HomeModule());
  }
}
