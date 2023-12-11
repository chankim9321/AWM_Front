import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/LoginPage/register_page.dart';
import 'package:mapdesign_flutter/Screen/home_screen.dart';
import 'package:mapdesign_flutter/components/my_button.dart';
import 'package:mapdesign_flutter/components/my_textfield.dart';
import 'package:mapdesign_flutter/components/square_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final idController = TextEditingController();
  final storage = SecureStorage();
  final passwordController = TextEditingController();

  void signUserIn() async {
    // show loading circle
    showDialog(context: context, barrierDismissible: false, builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
    // login API
    try{
      // login through http request
      final response = await http.post(
        Uri.parse('http://${ServerConf.url}/login'), // api login urㅣ
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "userId": idController.text,
          "password": passwordController.text
        })
      );
      // if response is OK
      if(response.statusCode == 200){

        final String accessToken = response.headers['authorization']!;

        storage.writeSecureData("token", accessToken);

        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MapScreen()));
      }else{
        // error handling required
        CustomDialog.showCustomDialog(context, "로그인 실패!", "ID 또는 Password가 잘못 되었습니다.");
        Navigator.of(context, rootNavigator: true).pop();
      }
    }catch(e){
      // network error handling
      CustomDialog.showCustomDialog(context, "네트워크 오류!", "서버와의 응답이 없습니다. 다시 시도해주세요.");
      Navigator.of(context, rootNavigator: true).pop();
    }

  }
  void startMainPage() async{
    showDialog(context: context, builder: (context){
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
    // 로그인 프로세스 요구(백엔드에 요청)
    await Future.delayed(Duration(seconds: 2));
    // 인디케이터를 닫기
    Navigator.of(context, rootNavigator: true).pop();

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MapScreen()));
    // 메인페이지로 이동
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(height: 50),
                // Icon(
                //   Icons.lock_person,
                //   size: 150,
                // ),
                // SizedBox(height: 10),
                SizedBox(height: 100,),
                //welcome back you been missed
                // Text(
                //   'Welcome back you \'ve been missed',
                //   style: TextStyle(
                //     color: Colors.grey[700],
                //     fontSize: 15,
                //   )
                // ),
                SizedBox(height: 25),
                //username
                MyTextField(
                    controller: idController,
                    hintText: '아이디를 입력해주세요',
                    obscureText: false,
                ),
                SizedBox(height: 15),
                //password
                MyTextField(
                    controller: passwordController,
                    hintText: '비밀번호를 입력해주세요',
                    obscureText: true
                ),
                SizedBox(height: 15),
                MyButton(
                    onTap: signUserIn,
                    text: '로그인',
                ),
                SizedBox(height: 20),

                MyButton(
                  onTap: startMainPage,
                  text: '로그인 없이 시작하기',
                ),
                SizedBox(height: 20),
                // forgot password

                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '로그인 정보를 잊어버렸나요?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        )
                      ),
                      Text(
                        ' 도움을 요청하세요! ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                
                // continue with
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.white),
                        )
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey.shade400,
                        )
                      )
                    ],
                  ),
                ),
                SizedBox(height: 60),
                
                //google + apple button
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 다른 계정으로 로그인(파이어베이스 요구됨)
                    SquareTile(imagePath: 'asset/icons/btn_google.svg', height: 40, onTap: () => {}, notice: "Continue with Google",),
                    SizedBox(height: 20),
                    SquareTile(imagePath: 'asset/icons/btn_naver.svg', height: 40, onTap: () => {}, notice: "Continue with Naver",)
                  ],
                ),
                SizedBox(height: 20),
                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member? ',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage(onTap: () {})),
                        );
                      },
                      child: Text(
                        'Register Now!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      )
    );
  }
}
