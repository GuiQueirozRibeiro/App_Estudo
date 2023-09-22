import 'package:flutter_modular/flutter_modular.dart';

import 'view/page/auth_page.dart';
import 'view/page/login_page.dart';

class AuthModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (_) => const AuthPage());
    r.child(
      '/login',
      child: (_) => LoginPage(
        isStudant: r.args.data,
      ),
      transition: TransitionType.fadeIn,
    );
  }
}
