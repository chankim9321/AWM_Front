import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/components/introduction_page_text.dart';
import 'package:mapdesign_flutter/components/my_button.dart';

class IntroductionSecondPage extends StatelessWidget {
  const IntroductionSecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Column(
            children: [
              Expanded(child: SizedBox()), // 추가
              Container( // 추가
                padding: const EdgeInsets.only(left: 16.0), // 왼쪽 패딩 추가
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                    children: const [
                      IntroductionPageText(introductionText: "사용자들이 제공하는 실시간 위치 정보!"),
                      SizedBox(height: 20,),
                      IntroductionPageText(introductionText: "내 주변의 특별한 장소나 이벤트를 발견하세요."),
                      SizedBox(height: 20,),
                      IntroductionPageText(introductionText: "사용자들의 평가와 후기를 통해 믿을 수 있는 정보만을 받아보세요."),
                      SizedBox(height: 20,),
                    ]
                ),
              ),
              Expanded(child: SizedBox()), // 추가
              MyButton(
                // 버튼 누를시 바로 MainPage로 라우팅
                  onTap: () => {},
                  text: "Skip and Start!"
              ),
              SizedBox(height: 100,),
            ]
        )
    );
  }
}
