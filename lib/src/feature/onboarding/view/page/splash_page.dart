import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/onboarding_view_model.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<OnboardingViewModel>(context, listen: false);
    _viewModel.checkOnboardingStatus(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/assets/images/cmcs_icon.png"),
            const SizedBox(height: 50),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
