import 'package:flutter_modular/flutter_modular.dart';

import 'feature/auth/auth_module.dart';
import 'feature/onboarding/onboarding_module.dart';

class AppModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.module('/', module: OnBoardingModule());
    r.module('/auth', module: AuthModule());
  }
}
