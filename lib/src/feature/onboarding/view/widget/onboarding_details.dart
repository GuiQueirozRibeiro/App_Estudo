import 'package:flutter/material.dart';
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
                  color: Theme.of(context).colorScheme.tertiary,
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
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
        SizedBox(height: screenHeight * 0.04),
        Image.asset(widget.imagePath),
        SizedBox(height: screenHeight * 0.04),
        if (widget.isTitle)
          Column(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
      ],
    );
  }
}
