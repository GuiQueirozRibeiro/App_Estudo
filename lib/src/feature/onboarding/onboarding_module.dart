import 'package:flutter_modular/flutter_modular.dart';

import '../auth/auth_module.dart';
import '../home/home_module.dart';
import 'view/page/onboarding_page.dart';

class OnBoardingModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (context) => const OnBoardingScreen());
    r.module('/home', module: HomeModule());
    r.module('/auth', module: AuthModule());
  }
}
