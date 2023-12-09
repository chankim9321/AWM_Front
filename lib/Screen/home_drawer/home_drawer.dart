import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/UserAPIs/user_profile.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/Screen/home_drawer/profile_modify.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  String? loginBanner = "로그인";
  String defaultNickname = "익명";
  String? nickname = "???";
  List<Uint8List> profileImage = [];
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
    }else{
      loginBanner = "로그인";
    }
    setState(() {

    });
  }
  Future<void> _loadUserProfile() async {
    try{
      if (token != null){
        var data = await UserProfile.getUserProfile();
        nickname = data['nickname'];
        profileImage = data['image'];
        print("성공?");
      }
    }catch(e){
      print("error");
      nickname = defaultNickname;
      profileImage = [];
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
    await _loadUserProfile();
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
