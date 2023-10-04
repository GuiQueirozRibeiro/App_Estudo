import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:localization/localization.dart';
import 'package:provider/provider.dart';

import '../../../../common/widgets/custom_button.dart';
import '../../viewmodel/onboarding_view_model.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OnboardingViewModel>(builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              viewModel.buildPageView(context),
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
                          Modular.to.navigate('/auth/');
                        },
                        buttonText: 'skip'.i18n(),
                        size: viewModel.screen,
                      ),
                    CustomButton(
                      size: viewModel.screen,
                      buttonText:
                          viewModel.currentPage == viewModel.pages.length - 1
                              ? 'done'.i18n()
                              : 'next'.i18n(),
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
      }),
    );
  }
}
