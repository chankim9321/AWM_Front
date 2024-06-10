
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mapdesign_flutter/APIs/UserAPIs/user_profile.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/LocationInfo/marker_clicked.dart';
import 'package:mapdesign_flutter/LocationInfo/modify_page.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/Screen/Weather_View/weather_background.dart';
import 'package:mapdesign_flutter/Screen/Weather_View/weather_report_view.dart';
import 'package:mapdesign_flutter/Screen/category_selector.dart';
import 'package:mapdesign_flutter/Screen/home_drawer/profile_modify.dart';
import 'package:mapdesign_flutter/Screen/recommended_user_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/user_info.dart';
import 'package:mapdesign_flutter/LocationInfo/about_this_place.dart';
import 'package:mapdesign_flutter/LocationInfo/place_info.dart';
import 'package:upstash_redis/upstash_redis.dart';

import '../../community/socket_chat.dart';
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
  String defaultProfile = "asset/img/default_profile.PNG";
  bool isLogined() {
    if (token != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _checkLogined() async {
    if (token != null) {
      loginBanner = "로그아웃";
      nickname = UserInfo.userNickname;
      profileImage = UserInfo.profileImage;
    } else {
      loginBanner = "로그인";
      nickname = defaultNickname;
    }
    setState(() {});
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

    return Drawer(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade800,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: backgroundImage,
                  radius: 40,
                ),
                accountName: Text(
                  nickname!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 자기소개란으로 설정해보자
                accountEmail: Text(
                  "AnyWhere Map",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                  ),
                ),
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.solidUser,
                text: '프로필 수정',
                onTap: () {
                  if (isLogined()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileModifyPage(
                          nickname: nickname!,
                          profileImage: profileImage,
                        ),
                      ),
                    );
                  } else {
                    CustomDialog.showCustomDialog(
                        context, "로그인", "로그인이 필요합니다.");
                  }
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.trophy,
                text: '랭킹',
                onTap: () {},
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.icons,
                text: '관심목록 설정',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return CategorySelector(); // Your custom widget
                    },
                  );
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.userPlus,
                text: '유저 추천',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendUserScreen(),
                    ),
                  );
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.cloudSunRain,
                text: '날씨 입력',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherSelectionScreen(),
                    ),
                  );
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.cloudSunRain,
                text: '현재위치 날씨',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => WeatherPage(),
                      builder: (context) => WeatherBackgroundPage(),
                    ),
                  );
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.gear,
                text: '설정',
                onTap: () {},
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.rightFromBracket,
                text: loginBanner!,
                onTap: () {
                  SecureStorage().deleteSecureData("token");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginModule()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
              // Test용 리스트 타일
              // _createDrawerItem(
              //   icon: Icons.help,
              //   text: '테스트 라우트 1',
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => ChatScreen(
              //           locationId: 1,
              //           nickName: UserInfo.userNickname,
              //         ),
              //       ),
              //     );
              //   },
              // ),
              // _createDrawerItem(
              //   icon: Icons.help,
              //   text: '테스트 라우트 2',
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => ModifyScreen(locationId: 1)
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
        required String text,
        GestureTapCallback? onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.white),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
