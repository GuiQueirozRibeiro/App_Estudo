import 'package:flutter_modular/flutter_modular.dart';

import 'view/page/forgot_password_screen.dart';
import 'view/page/signup_screen.dart';
import 'view/page/login_screen.dart';
import '../home/home_module.dart';

class AuthModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (_) => const LoginScreen());
    r.child(
      '/signup',
      child: (_) => const SignupScreen(),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/forgotPassword',
      child: (_) => const ForgotPasswordScreen(),
      transition: TransitionType.fadeIn,
    );
    r.module('/home', module: HomeModule());
  }
}
