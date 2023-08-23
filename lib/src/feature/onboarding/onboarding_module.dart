import 'package:flutter_modular/flutter_modular.dart';

import '../auth/auth_module.dart';
import '../home/home_module.dart';
import 'view/page/onboarding_page.dart';
import 'view/page/splash_page.dart';
import 'viewmodel/onboarding_view_model.dart';

class OnBoardingModule extends Module {
  @override
  void binds(i) {
    i.addLazySingleton(() => OnboardingViewModel());
  }

  @override
  void routes(r) {
    r.child('/', child: (context) => const SplashPage());
    r.child('/onboarding', child: (context) => const OnBoardingPage());
    r.module('/home', module: HomeModule());
    r.module('/auth', module: AuthModule());
  }
}
