
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/components/my_button.dart';
import 'package:mapdesign_flutter/components/my_textfield.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapdesign_flutter/components/square_tile.dart';


class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();

  void signUserUp() async {
    // show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    // try {
    //   // check if both password and confirm pasword is same
    //   if (passwordController.text == confirmPasswordController.text) {
    //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
    //       email: emailController.text,
    //       password: passwordController.text,
    //     );
    //   } else {
    //     //show error password dont match
    //     genericErrorMessage("Password don't match!");
    //   }
    //
    //   //pop the loading circle
    //   Navigator.pop(context);
    // } on FirebaseAuthException catch (e) {
    //   //pop the loading circle
    //   Navigator.pop(context);
    //
    //   genericErrorMessage(e.code);
    // }
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken
          ),
          fit: BoxFit.cover,
          image: AssetImage('asset/flutter_asset/asset2.jpg')
        )
      ),
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

                  //username
                  MyTextField(
                    controller: emailController,
                    hintText: 'Username or email',
                    obscureText: false,
                  ),

                  const SizedBox(height: 15),
                  //password
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),

                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  // phone Number
                  MyTextField(
                    controller: phoneNumberController,
                    hintText: 'Enter your phone number(except "-")',
                    obscureText: false,
                  ),
                  const SizedBox(height: 15),

                  //sign in button
                  MyButton(
                    onTap: signUserUp,
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
                          padding: const EdgeInsets.only(left: 8, right: 8),
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
                      SquareTile(imagePath: 'asset/icons/google.svg', height: 40, onTap: () => {}, notice: "Continue with Google",),
                      SizedBox(height: 20),
                      SquareTile(imagePath: 'asset/icons/Vector.svg', height: 40, onTap: () => {}, notice: "Continue with Apple",)
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
      )
    );
  }
}
