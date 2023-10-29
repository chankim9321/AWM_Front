import 'package:flutter/material.dart';

class IntroductionPageText extends StatelessWidget {
  final String introductionText;
  const IntroductionPageText({
    super.key,
    required this.introductionText,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      introductionText,
      style: TextStyle(
        color: Colors.white,
        fontSize: 23,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.left, // 왼쪽 정렬
    );
  }
}