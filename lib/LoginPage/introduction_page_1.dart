import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/components/my_button.dart';
import 'package:mapdesign_flutter/components/introduction_page_text.dart';

class IntroductionFirstPage extends StatelessWidget {
  const IntroductionFirstPage({super.key, required this.setLastPage});
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
                      IntroductionPageText(introductionText: "함께 만드는 우리 동네 지도!"),
                      SizedBox(height: 20,),
                      IntroductionPageText(introductionText: "집단지성을 통한 주변정보 획득!"),
                      SizedBox(height: 20,),
                    ]
                ),
              ),
              Expanded(child: SizedBox()), // 추가
              MyButton(
                // 버튼 누를시 바로 login page로 라우팅
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

