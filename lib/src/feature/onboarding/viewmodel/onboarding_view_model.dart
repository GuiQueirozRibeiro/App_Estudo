import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/widget/onboarding_details.dart';

class OnboardingViewModel {
  late SharedPreferences prefs;

  int currentPage = 0;
  bool isLoading = true;
  double screenWidth = 0.0;
  double screenHeight = 0.0;

  final PageController pageController = PageController(initialPage: 0);
  final List<Widget> pages = [
    OnBoardingDetails(
      title: 'onboard_title1'.i18n(),
      subtitle: 'onboard_sub_title1'.i18n(),
      imagePath: 'lib/assets/images/onboarding1.gif',
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

  void init(BuildContext context) async {
    await checkOnboardingStatus();
  }

  Future<void> checkOnboardingStatus() async {
    prefs = await SharedPreferences.getInstance();
    bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    if (onboardingCompleted) {
      await Modular.to.pushReplacementNamed('/auth/');
    }
    isLoading = false;
  }

  void goToNextPage() {
    if (currentPage < pages.length - 1) {
      currentPage++;
    } else {
      prefs.setBool('onboardingCompleted', true);
      Modular.to.navigate('/auth/');
    }
  }

  void goToPreviousPage() {
    if (currentPage > 0) {
      currentPage--;
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
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
