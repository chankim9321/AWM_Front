import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/components/introduction_page_text.dart';
import 'package:mapdesign_flutter/components/my_button.dart';

class IntroductionThirdPage extends StatelessWidget {
  const IntroductionThirdPage({super.key, required this.setLastPage});
  final void Function() setLastPage;
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
                      IntroductionPageText(introductionText: "우리 모두의 활발한 활동을 통해\n더욱 풍부한 지도를 만들어가요!"),
                      SizedBox(height: 20,),
                      IntroductionPageText(introductionText: "커뮤니티의 일원으로서\n정보의 정확성을 유지해주세요."),
                      SizedBox(height: 20,),
                    ]
                ),
              ),
              Expanded(child: SizedBox()), // 추가
              MyButton(
                // 버튼 누를시 바로 MainPage로 라우팅
                  onTap: () {
                    setLastPage!();
                    },
                  text: "Skip and Start!"
              ),
              SizedBox(height: 100,),
            ]
        )
    );
  }
}