import 'package:flutter_modular/flutter_modular.dart';

import 'view/page/splash_load_page.dart';
import '../home/home_module.dart';

class SplashModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const SplashLoadPage());
    r.module('/home/', module: HomeModule());
  }
}
