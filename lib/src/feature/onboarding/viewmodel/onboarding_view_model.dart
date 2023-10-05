import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/viewmodel/auth_view_model.dart';
import '../../auth/repository/user_model.dart';
import '../view/widget/onboarding_details.dart';

class OnboardingViewModel extends ChangeNotifier {
  late AuthViewModel auth;
  late SharedPreferences prefs;

  int currentPage = 0;

  final PageController pageController = PageController(initialPage: 0);

  final List<Widget> pages = [
    OnBoardingDetails(
      title: 'onboard_title1'.i18n(),
      subtitle: 'onboard_sub_title1'.i18n(),
      imagePath: 'lib/assets/images/cmcs_icon.png',
      isTitle: true,
    ),
    OnBoardingDetails(
      title: 'onboard_title2'.i18n(),
      subtitle: 'onboard_sub_title2'.i18n(),
      imagePath: 'lib/assets/images/onboarding2.gif',
      isTitle: false,
    ),
    OnBoardingDetails(
      title: 'onboard_title3'.i18n(),
      subtitle: 'onboard_sub_title3'.i18n(),
      imagePath: 'lib/assets/images/onboarding3.gif',
      isTitle: false,
    ),
  ];

  Widget buildPageView(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller: pageController,
        itemCount: pages.length,
        itemBuilder: (BuildContext context, int index) {
          return pages[index % pages.length];
        },
        onPageChanged: (int page) {
          currentPage = page;
          notifyListeners();
        },
      ),
    );
  }

  Future<void> checkOnboardingStatus(BuildContext context) async {
    auth = Provider.of<AuthViewModel>(context, listen: false);
    prefs = await SharedPreferences.getInstance();
    bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    if (onboardingCompleted) {
      auth.userChanges.listen((UserModel? user) async {
        if (user != null) {
          Modular.to.navigate('/splash/');
        } else {
          Modular.to.navigate('/auth/');
        }
      });
    } else {
      Modular.to.pushReplacementNamed('/onboarding');
    }
  }

  void goToNextPage() {
    if (currentPage < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      prefs.setBool('onboardingCompleted', true);
      Modular.to.navigate('/auth/');
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  List<Widget> buildPageIndicators(BuildContext context) {
    return List<Widget>.generate(pages.length, (index) {
      return _indicator(context, index == currentPage);
    });
  }

  Widget _indicator(BuildContext context, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 16.0 : 10.0,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
