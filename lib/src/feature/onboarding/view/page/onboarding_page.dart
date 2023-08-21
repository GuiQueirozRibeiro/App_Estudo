import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_button.dart';
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
    _viewModel = Provider.of<OnboardingViewModel>(context, listen: false);
    _viewModel.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _viewModel.buildPageView(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: viewModel.buildPageIndicators(context),
                  ),
                  SizedBox(height: viewModel.screen.height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: viewModel.screen.width * 0.04,
                      vertical: viewModel.screen.height * 0.02,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          size: viewModel.screen,
                          buttonText: 'back'.i18n(),
                          onPressed: () {
                            viewModel.goToPreviousPage();
                          },
                        ),
                        if (viewModel.currentPage != 2)
                          CustomButton(
                            onPressed: () {
                              viewModel.prefs
                                  .setBool('onboardingCompleted', true);
                              Modular.to.navigate('/auth/');
                            },
                            buttonText: 'skip'.i18n(),
                            size: viewModel.screen,
                          ),
                        CustomButton(
                          size: viewModel.screen,
                          buttonText: viewModel.currentPage ==
                                  viewModel.pages.length - 1
                              ? 'Done'.i18n()
                              : 'Next'.i18n(),
                          onPressed: () {
                            viewModel.goToNextPage();
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
