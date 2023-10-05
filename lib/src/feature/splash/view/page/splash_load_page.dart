import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/splash_view_model.dart';

class SplashLoadPage extends StatefulWidget {
  const SplashLoadPage({super.key});

  @override
  State<SplashLoadPage> createState() => _SplashLoadPageState();
}

class _SplashLoadPageState extends State<SplashLoadPage> {
  late SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SplashViewModel>(context, listen: false);

    Future.delayed(Duration.zero, () {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await _viewModel.loadData(context);
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
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
