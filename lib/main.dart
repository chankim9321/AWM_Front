import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/LoginPage/login_module.dart';
import 'package:mapdesign_flutter/Screen/home_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mapdesign_flutter/LocationInfo/place_info.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await _initNotiSetting();//local Notifcation 초기 설정
  runApp(MyApp());
}
//local Notification
Future<void> _initNotiSetting() async {
  //Notification plugin object init
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // 안드로이드 초기 설정 (위에서 만든 아이콘도 같이 등록)
  final AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('ic_launcher');
  //IOS 초기 설정
  final IOSInitializationSettings initSettingsIOS = IOSInitializationSettings(requestSoundPermission: true, requestAlertPermission: true, requestBadgePermission: true);
  //Notification에 위에서 설정한 안드로이드, IOS 초기 설정 값 삽입
  final InitializationSettings initSettings = InitializationSettings(android: initSettingsAndroid, iOS: initSettingsIOS,);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: LoginModule()
      //debugShowCheckedModeBanner: false,
    );
  }
}
