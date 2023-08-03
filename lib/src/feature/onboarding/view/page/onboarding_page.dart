import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/onboarding_details.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  late SharedPreferences prefs;
  int _currentPage = 0;
  bool isLoading = true;

  final PageController _pageController = PageController(initialPage: 0);
  final List<Widget> _pages = [
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

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _pages.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    checkOnboardingStatus(context);
  }

  Widget _indicator(bool isActive) {
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

  Future<void> checkOnboardingStatus(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    if (onboardingCompleted) {
      await Modular.to.pushReplacementNamed('/auth/');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.outline,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _pages[index % _pages.length];
                      },
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 20,
                          ),
                          onPressed: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            }
                          },
                          child: Text(
                            'back'.i18n(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        _currentPage != 2
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 20,
                                ),
                                onPressed: () {
                                  prefs.setBool('onboardingCompleted', true);
                                  Modular.to.navigate('/auth/');
                                },
                                child: Text(
                                  'skip'.i18n(),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              )
                            : const Text(''),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 20,
                          ),
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease);
                            } else {
                              prefs.setBool('onboardingCompleted', true);
                              Modular.to.navigate('/auth/');
                            }
                          },
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Done'.i18n()
                                : 'Next'.i18n(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
