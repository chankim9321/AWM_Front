import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    // 필요한 추가 스코프를 여기에 추가하세요
  ],
);

Future<void> signUpWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      // Google 로그인 성공, 사용자 정보를 가져옵니다.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 구글에서 제공한 토큰을 백엔드로 전송하여 사용자를 인증합니다.
      final String accessToken = googleAuth.accessToken!;

      final String idToken = googleAuth.idToken!;

      // 백엔드로 토큰 전송 및 사용자 등록 로직 구현
      // 예: HTTP POST 요청을 통해 토큰과 함께 사용자 정보를 백엔드로 전송
      // 백엔드는 이 정보를 사용하여 사용자가 새로운 사용자인지 확인하고, 새로운 사용자라면 회원가입 처리를 합니다.
      try{
        // http request
        final response = await http.post(
          Uri.parse(''), // API URL
          body: {
            accessToken: accessToken,
            idToken: idToken
          },
        );
        // if response is OK
        if(response.statusCode == 200){
          final storage = FlutterSecureStorage();
          final responseData = json.decode(response.body);

          final String token = responseData['token'];

          await storage.write(key: 'token', value: token);

        }else{
          // error handling required
          CustomDialog.showCustomDialog(context, "실패", "로그인에 실패했습니다!");
        }
      }catch(e){
        // network error handling required
        CustomDialog.showCustomDialog(context, "실패", "서버와의 접속이 끊겼습니다!");
      }

    }
  } catch (error) {
    // 회원가입 실패 처리
    print("Failed!");
  }
}
