import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({
    super.key, required this.text, required this.fontSize, required this.color
  });
  final String text;
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2.0, 2.0),
            ),
          ]
      ),
    );
  }
}
