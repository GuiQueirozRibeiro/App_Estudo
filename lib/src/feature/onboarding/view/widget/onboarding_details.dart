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

  void loadGifs() {}

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    GifController controller = GifController(vsync: this);

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
        Gif(
          image: AssetImage(widget.imagePath),
          controller: controller,
          autostart: Autostart.loop,
          duration: const Duration(seconds: 3),
          placeholder: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          onFetchCompleted: () {
            controller.reset();
            controller.forward();
          },
          width: screenWidth * 0.9,
          height: screenHeight * 0.4,
          fit: BoxFit.cover,
        ),
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
