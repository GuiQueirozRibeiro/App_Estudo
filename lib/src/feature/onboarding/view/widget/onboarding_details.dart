import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:localization/localization.dart';

class OnBoardingDetails extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isTitle;

  const OnBoardingDetails({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isTitle,
  }) : super(key: key);

  @override
  State<OnBoardingDetails> createState() => OnBoardingDetailsState();
}

class OnBoardingDetailsState extends State<OnBoardingDetails>
    with TickerProviderStateMixin {
  late GifController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.06),
        widget.isTitle
            ? Text(
                'app_name'.i18n(),
                style: TextStyle(
                  fontSize: screenWidth * 0.1,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              )
            : Column(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
        SizedBox(height: screenHeight * 0.04),
        widget.isTitle
            ? Image.asset(widget.imagePath)
            : Gif(
                image: AssetImage(widget.imagePath),
                controller: _controller,
                autostart: Autostart.loop,
                placeholder: (context) => Image.asset(widget.imagePath),
                onFetchCompleted: () {
                  _controller.reset();
                  _controller.forward();
                },
                width: widget.imagePath == 'lib/assets/images/onboarding3.gif'
                    ? screenWidth * 0.6
                    : screenWidth,
                height: widget.imagePath == 'lib/assets/images/onboarding3.gif'
                    ? screenHeight * 0.35
                    : screenHeight * 0.3,
                fit: BoxFit.cover,
              ),
        SizedBox(height: screenHeight * 0.04),
        if (widget.isTitle)
          Column(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
      ],
    );
  }
}
