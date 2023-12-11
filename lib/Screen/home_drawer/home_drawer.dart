import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/UserAPIs/user_profile.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/Screen/category_selector.dart';
import 'package:mapdesign_flutter/Screen/home_drawer/profile_modify.dart';
import 'package:mapdesign_flutter/Screen/recommended_user_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/user_info.dart';
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  String? loginBanner = "로그인";
  String defaultNickname = "익명의 유저";
  String? nickname = "???";
  Uint8List profileImage = Uint8List(0);
  String? token;
  String defaultProfile = "asset/img/default_profile.jpeg";

  bool isLogined(){
    if (token != null){
      return true;
    }else{
      return false;
    }
  }
  Future<void> _checkLogined() async{
    if (token != null){
      loginBanner = "로그아웃";
      nickname = UserInfo.userNickname;
      profileImage = UserInfo.profileImage;
    }else{
      loginBanner = "로그인";
      nickname = defaultNickname;
    }
    setState(() {

    });
  }
  Future<void> _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }
  Future<void> _initializeAsync() async {
    await _setToken(); // _setToken()이 완료될 때까지 기다림
    await _checkLogined();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeAsync();
  }
  @override
  Widget build(BuildContext context) {
    ImageProvider backgroundImage;
    backgroundImage = AssetImage(defaultProfile);

    if (profileImage.isNotEmpty) {
      backgroundImage = MemoryImage(profileImage);
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
                            SizedBox(
                              width: 80.0,
                              height: 80.0,
                              child: CircleAvatar(
                                radius: 50.0,
                                backgroundImage: backgroundImage,
                              ),
                            ),
                            SizedBox(height: 5.0,),
                            Text(nickname!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfileModifyPage(
                                        nickname: nickname!,
                                        profileImage: profileImage,
                                      ))
                                  );
                                }else{
                                  CustomDialog.showCustomDialog(context, "로그인", "로그인이 필요합니다.");
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
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CategorySelector(); // Your custom widget
                                  },
                                );
                              },
                              leading: Icon(
                                Icons.list_alt_outlined,
                                color: Colors.white,
                              ),
                              title: Text("관심목록 설정", style: TextStyle(color: Colors.white),),
                            ),
                            ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RecommendUserScreen())
                                );
                              },
                              leading: Icon(
                                Icons.list_alt_outlined,
                                color: Colors.white,
                              ),
                              title: Text("유저 추천", style: TextStyle(color: Colors.white),),
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
