import 'package:flutter_modular/flutter_modular.dart';

import 'view/page/navegation_page.dart';
import 'view/page/subject_details_page.dart';

class HomeModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child('/', child: (_) => const NavegationPage());
    r.child(
      '/details',
      child: (_) => SubjectDetailsPage(subject: r.args.data),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/edit',
      child: (_) => SubjectDetailsPage(subject: r.args.data),
      transition: TransitionType.fadeIn,
    );
  }
}
