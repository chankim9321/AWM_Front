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
    // 백엔드로 토큰 전송 및 사용자 등록 로직 구현
    // 예: HTTP POST 요청을 통해 토큰과 함께 사용자 정보를 백엔드로 전송
    // 백엔드는 이 정보를 사용하여 사용자가 새로운 사용자인지 확인하고, 새로운 사용자라면 회원가입 처리를 합니다.
    // final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();
    // final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
    try{
      // http request
      // final accessToken = googleSignInAuthentication.accessToken;
      // print(accessToken);
      final response = await http.post(
        // 예시 IP 주소
        Uri.parse('http://172.20.10.6:8080/oauth2/authorization/google'), // API URL
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $accessToken'
        }
      );
      // if response is OK
      if(response.statusCode == 200){
        // Spring Security 에서 발급해준 토큰을 저장
        final storage = FlutterSecureStorage();
        final responseData = json.decode(response.body);
        final String token = responseData['token'];
        await storage.write(key: 'token', value: token);
      }else{
        // error handling required
        CustomDialog.showCustomDialog(context, "실패", "로그인에 실패했습니다!");
      }
    }catch(e){
      // networ error handling required
      CustomDialog.showCustomDialog(context, "실패", "서버와의 접속이 끊겼습니다!");
  }
}
