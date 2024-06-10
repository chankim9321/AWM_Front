import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/LoginPage/Oauth_login/google_login.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/components/my_button.dart';
import 'package:mapdesign_flutter/components/my_textfield.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'dart:convert';

import 'package:mapdesign_flutter/components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  void signUserIn() async {
    if(_formKey.currentState!.validate()){
      // show loading circle
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      // login API
      if (passwordController.text != confirmPasswordController.text) {
        CustomDialog.showCustomDialog(context, "회원가입", "두 비밀번호가 서로 다릅니다!");
        Navigator.pop(context);
        return;
      }
      try {
        // login through http request
        final response = await http.post(
          Uri.parse('http://${ServerConf.url}/auth/join'), // api login url
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'userId': idController.text,
            'password': passwordController.text,
            'email': emailController.text,
            'phoneNumber': phoneNumberController.text
          }),
        );
        // if response is OK
        if (response.statusCode == 200) {
          final token = response.headers['authorization'];
          storage.write(key: 'token', value: token);
          CustomDialog.showCustomDialog(context, "회원가입", "성공적으로 회원가입되었습니다!");
          Navigator.pop(context);
          Navigator.pop(context);
          return;
        }
        else{
          // error handling required
          print("회원가입 에러 - ${response.statusCode}");
          CustomDialog.showCustomDialog(context, "회원가입", "요청이 거부되었습니다.");
        }
      }  catch (e) {
        // network error handling
        CustomDialog.showCustomDialog(context, "회원가입", "서버와의 응답이 없습니다. 다시 시도해주세요.");
      }
      Navigator.pop(context);
    }
  }

  void genericErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5), BlendMode.darken),
                    fit: BoxFit.cover,
                    image: AssetImage('asset/flutter_asset/asset2.jpg'))),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        //logo

                        const SizedBox(height: 10),
                        //welcome back you been missed

                        const SizedBox(height: 25),

                        MyTextField(
                          controller: idController,
                          hintText: 'User ID',
                          obscureText: false,
                          validator: (value) {
                            // 추가
                            if (value == null || value.isEmpty) {
                              return 'User ID를 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        //user email
                        MyTextField(
                          controller: emailController,
                          hintText: 'email',
                          obscureText: false,
                          validator: (value) {
                            // 추가
                            if (value == null || value.isEmpty) {
                              return 'email을 입력해주세요.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),
                        //password
                        MyTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          obscureText: true,
                          validator: (value) {
                            // 추가
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        MyTextField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: true,
                          validator: (value) {
                            // 추가
                            if (value == null || value.isEmpty) {
                              return '비밀번호를 한번 더 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // phone Number
                        MyTextField(
                          controller: phoneNumberController,
                          hintText: 'Enter your phone number(except "-")',
                          obscureText: false,
                          validator: (value) {
                            // 추가
                            if (value == null || value.isEmpty) {
                              return '핸드폰 번호를 입력해주세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        //sign in button
                        MyButton(
                          onTap: signUserIn,
                          text: 'Sign Up',
                        ),
                        const SizedBox(height: 20),

                        // continue with
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),

                        //google + apple button

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 다른 계정으로 로그인(파이어베이스 요구됨)
                            SquareTile(
                              imagePath: 'asset/icons/btn_google.svg',
                              height: 40,
                              onTap: () async {
                                await signUpWithGoogle(context);
                              },
                              notice: "Continue with Google",
                            ),
                            SizedBox(height: 20),
                            SquareTile(
                              imagePath: 'asset/icons/btn_naver.svg',
                              height: 40,
                              onTap: () => {},
                              notice: "Continue with Naver",
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        // not a memeber ? register now
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                'Login now',
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
