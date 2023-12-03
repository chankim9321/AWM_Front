import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/UserAPIs/user_profile.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/LoginPage/login_page.dart';
import 'package:mapdesign_flutter/Screen/home_drawer/profile_modify.dart';
import 'dart:math';

import 'package:mapdesign_flutter/Screen/home_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {

  String? loginBanner;
  String nickname = "익명의 유저";
  List<Uint8List> profileImage = [];
  String defaultProfile = "asset/img/default_profile.jpeg";
  bool isLogined(){
    if (SecureStorage().readSecureData('token') != null){
      return true;
    }else{
      return false;
    }
  }
  void _checkLogined(){
    if (SecureStorage().readSecureData('token') != null){
      loginBanner = "로그아웃";
    }else{
      loginBanner = "로그인";
    }
  }
  void _loadUserProfile() async {
    try{
      if (SecureStorage().readSecureData('token') != null){
        var data = await UserProfile.getUserProfile();
        nickname = data['nickname'];
        profileImage = data['profile'];
      }
    }catch(e){
      nickname = "익명의 유저";
      profileImage = [];
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLogined();
    _loadUserProfile();
  }
  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage;

    if (profileImage.isNotEmpty && profileImage[0] is Uint8List) {
      backgroundImage = MemoryImage(profileImage[0]);
    } else {
      backgroundImage = AssetImage(defaultProfile);
    }
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
                          children: [
                            CircleAvatar(
                              radius: 50.0,
                              backgroundImage: backgroundImage,
                            ),
                            SizedBox(height: 10.0,),
                            Text(nickname,
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
                              onTap: () {
                                if(isLogined()){
                                  CustomDialog.showCustomDialog(context, "로그인", "로그인이 필요합니다.");
                                }else{
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfileModifyPage(
                                        nickname: nickname,
                                        profileImage: profileImage,
                                      ))
                                  );
                                }
                              },
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
