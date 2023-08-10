import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';

import '../../viewmodel/onboarding_view_model.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  OnBoardingScreenState createState() => OnBoardingScreenState();
}

class OnBoardingScreenState extends State<OnBoardingScreen> {
  late OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Modular.get<OnboardingViewModel>();
    _viewModel.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _viewModel.isLoading
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
                      controller: _viewModel.pageController,
                      itemCount: _viewModel.pages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _viewModel
                            .pages[index % _viewModel.pages.length];
                      },
                      onPageChanged: (int page) {
                        _viewModel.currentPage = page;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _viewModel.buildPageIndicators(context),
                  ),
                  SizedBox(height: _viewModel.screenHeight * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _viewModel.screenWidth * 0.04,
                      vertical: _viewModel.screenHeight * 0.02,
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
                            _viewModel.goToPreviousPage();
                          },
                          child: Text(
                            'back'.i18n(),
                            style: TextStyle(
                              fontSize: _viewModel.screenWidth * 0.05,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                        if (_viewModel.currentPage != 2)
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
                              _viewModel.prefs
                                  .setBool('onboardingCompleted', true);
                              Modular.to.navigate('/auth/');
                            },
                            child: Text(
                              'skip'.i18n(),
                              style: TextStyle(
                                fontSize: _viewModel.screenWidth * 0.05,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ),
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
                            _viewModel.goToNextPage();
                          },
                          child: Text(
                            _viewModel.currentPage ==
                                    _viewModel.pages.length - 1
                                ? 'Done'.i18n()
                                : 'Next'.i18n(),
                            style: TextStyle(
                              fontSize: _viewModel.screenWidth * 0.05,
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
