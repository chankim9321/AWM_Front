import 'dart:convert';
import 'dart:ui';

import 'package:geolocator/geolocator.dart';
import 'redis_connector.dart';
import 'device_id_creator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'web_socket.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';


class NotificationService {
  final _redisClient = RedisClient();
  final _deviceInfo = DeviceIDCreator();
  late WebSocketService _webSocketService;
  final _backend_socket_server = "test";
  NotificationService() {
    _init();
  }
  // 현재 위치를 가져오는 함수
  void _init() {
    String _deviceId = _deviceInfo.getDeviceId();
    _webSocketService = WebSocketService(_backend_socket_server);
    // 클라이언트가 연결되면 자신의 ID를 서버에 전송
    _webSocketService.sendMessage(jsonEncode({'type': 'register', 'deviceId': _deviceId}));

    _webSocketService.messages.listen((message) {
      final decodedMessage = jsonDecode(message);
      String title = decodedMessage["title"];

      String location_id = decodedMessage["location_id"];
      // 여기에 로컬 알림을 띄우는 코드를 추가하세요.

    });
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          distanceFilter: 10,  // 위치가 10m 이상 변경되었을 때만 업데이트
        )
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    // Redis에 위치 업데이트 로직 구현
    print("New location: ${position.latitude}, ${position.longitude}");
    _redisClient.saveUserLocation(position.latitude.toString(), position.longitude.toString());
  }
  // 웹 소켓 연결 해제
  void dispose() {
    _webSocketService.close();
  }
  Future ClockTimeNotification(String notiTitle, String notiDesc) async {
    final result;//권한 확인을 위한 변수
    //----------------------------------------------------------------------------------
    //local notification 플러그인 객체 생성
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //플랫폼 확인해서 OS 종류에 따라 권한 확인
    //안드로이드 일때
    if(Platform.isAndroid){
      result=true;
    }
    //IOS 일때
    else{
      result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    //----------------------------------------------------------------------------------
    // 안드로이드 Notification 옵션
    var android = AndroidNotificationDetails('id', notiTitle,
        channelDescription: notiDesc,
        importance: Importance.max,
        priority: Priority.max,
        color: const Color.fromARGB(255, 255, 0, 0)
    ); // Notification Icon 배경색

    //IOS Notification 옵션
    var ios = IOSNotificationDetails();
    //Notificaiton 옵션 값 등록
    var detail = NotificationDetails(android: android, iOS: ios);
    //----------------------------------------------------------------------------------
    //권한이 있으면 실행.
    if (result==true) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannelGroup('id');

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // 스케줄 ID(고유)
        notiTitle, //알람 제목
        notiDesc, //알람 내용
        _setNotiTime(), //알람 시간
        detail,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        //이 옵션은 중요함(옵션 값에따라 시간만 맞춰서 작동할지, 월,일,시간 모두 맞춰서 작동할지 옵션 설정
        //아래와 같이 time으로 설정되어있으면, setNotTime에서 날짜를 아무리 지정해줘도 시간만 동일하면 알림이 발생
        matchDateTimeComponents: DateTimeComponents.time,//또는dayOfMonthAndTime
      );
    }
  }
  //알람 시간 세팅
  tz.TZDateTime _setNotiTime() {
    tz.initializeTimeZones();//TimeZone Database 초기화
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));//TimeZone 설정(외국은 다르게!)
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, 13, 06, 30);//알람 시간
    //var test = tz.TZDateTime.now(tz.local).add(const Duration (seconds: 5));
    print('-----------알람 시간 체크----${scheduledDate.toString()}');
    return scheduledDate;
  }

}