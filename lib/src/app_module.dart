import 'package:flutter_modular/flutter_modular.dart';

import 'feature/auth/auth_module.dart';
import 'feature/home/home_module.dart';
import 'feature/onboarding/onboarding_module.dart';
import 'feature/splash/splash_module.dart';

class AppModule extends Module {
  @override
  void routes(r) {
    r.module('/', module: OnBoardingModule());
    r.module('/auth/', module: AuthModule());
    r.module('/home/', module: HomeModule());
    r.module('/splash/', module: SplashModule());
  }
}
