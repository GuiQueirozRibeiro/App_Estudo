import 'package:flutter_modular/flutter_modular.dart';

import '../auth/auth_module.dart';
import '../home/home_module.dart';
import '../splash/splash_module.dart';
import 'view/page/onboarding_page.dart';
import 'view/page/splash_page.dart';

class OnBoardingModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (_) => const SplashPage());
    r.child('/onboarding', child: (_) => const OnBoardingPage());
    r.module('/auth/', module: AuthModule());
    r.module('/home/', module: HomeModule());
    r.module('/splash/', module: SplashModule());
  }
}
