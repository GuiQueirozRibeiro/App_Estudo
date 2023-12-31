import 'package:flutter_modular/flutter_modular.dart';

import 'view/page/activity_form_page.dart';
import 'view/page/navegation_page.dart';
import 'view/page/profile_details_page.dart';
import 'view/page/subject_details_page.dart';
import 'view/page/subject_form_page.dart';

class HomeModule extends Module {
  @override
  void routes(r) {
    r.child('/', child: (_) => const NavegationPage());
    r.child(
      '/profileDetails',
      child: (_) => ProfileDetailsPage(user: r.args.data),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/subjectFormPage',
      child: (_) => SubjectFormPage(subject: r.args.data),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/subjectDetails/',
      child: (_) => SubjectDetailsPage(subject: r.args.data),
      transition: TransitionType.fadeIn,
    );
    r.child(
      '/subjectDetails/activityFormPage',
      child: (_) => const ActivityFormPage(),
      transition: TransitionType.fadeIn,
    );
  }
}
