import 'package:flutter/material.dart';

class RecommendButton extends StatelessWidget {

  final VoidCallback onPressed;

  RecommendButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent, // 배경색을 투명으로 설정
          shadowColor: Colors.transparent, // 그림자색을 투명으로 설정
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 버튼의 둥근 모서리
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // 버튼 패딩
        ),
        child: Text(
          "🤖 AI가 추천하는 장소를 알고싶나요? 🤖",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'PretendardRegular',
          ),
        ),
      ),
    );
  }
}
