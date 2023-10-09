import 'package:flutter_modular/flutter_modular.dart';

import '../splash/splash_module.dart';
import 'view/page/auth_page.dart';
import 'view/page/login_page.dart';

class AuthModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const AuthPage());
    r.child(
      '/login',
      child: (_) => LoginPage(
        isProfessor: r.args.data,
      ),
      transition: TransitionType.fadeIn,
    );
    r.module('/splash/', module: SplashModule());
  }
}
