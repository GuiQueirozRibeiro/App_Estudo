import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool isBig;
  final Size size;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    this.isBig = true,
    required this.size,
    required this.buttonText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isBig ? screenWidth * 0.12 : screenWidth * 0.03,
          vertical: isBig ? screenHeight * 0.01 : screenHeight * 0.001,
        ),
        elevation: 20,
      ),
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: isBig ? screenWidth * 0.04 : screenWidth * 0.035,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
