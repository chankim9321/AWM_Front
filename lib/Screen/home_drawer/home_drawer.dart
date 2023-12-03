import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/LoginPage/login_page.dart';
import 'dart:math';

import 'package:mapdesign_flutter/Screen/home_screen.dart';
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {

  String? loginBanner;
  void checkLogined(){
    if (SecureStorage().readSecureData('token') != null){
      loginBanner = "로그아웃";
    }else{
      loginBanner = "로그인";
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogined();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
          children: [
            // creating background
            Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade800,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter
                    )
                ),
              child: Drawer(
                backgroundColor: Colors.transparent,
                width: 200.0,
                child: Column(
                  children: [
                    DrawerHeader(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircleAvatar(
                              radius: 50.0,
                              backgroundImage: AssetImage('asset/img/pepe.webp'),
                            ),
                            SizedBox(height: 10.0,),
                            Text("PePe The Frog",
                                style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              )
                            ),
                          ],
                        )
                    ),
                    Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              onTap: () {},
                              leading: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              title: Text("프로필 수정", style: TextStyle(color: Colors.white),),
                            ),
                            ListTile(
                              onTap: () {},
                              leading: Icon(
                                Icons.emoji_events_rounded,
                                color: Colors.white,
                              ),
                              title: Text("랭킹", style: TextStyle(color: Colors.white),),
                            ),
                            ListTile(
                              onTap: () {},
                              leading: Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              title: Text("설정", style: TextStyle(color: Colors.white),),
                            ),
                            ListTile(
                              onTap: () {
                                  SecureStorage().deleteSecureData("token");
                                  Navigator.pushAndRemoveUntil(
                                      context, MaterialPageRoute(
                                      builder: (context) => LoginModule()
                                    ), (Route<dynamic> route) => false
                                  );
                              },
                              leading: Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              title: Text(loginBanner!,
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        )
                    )
                  ],
                ),
              )
            ),
          ],
      ),
    );
  }
}
