import 'dart:convert';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/LocationInfo/about_this_place.dart';
import 'redis_connector.dart';
import 'device_id_creator.dart';
import 'web_socket.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';


class NotificationService {
  final GlobalKey<NavigatorState> _navigatorKey;
  final _redisClient = RedisClient();
  final _deviceInfo = DeviceIDCreator();
  late WebSocketService _webSocketService;
  final _backend_socket_server = "ws://${ServerConf.url}/alarm/ws";
  String previousLatitude = "";
  String previousLongitude = "";

  String? previous_key;
  static int _instanceCount = 0;

  NotificationService(this._navigatorKey) {
    _instanceCount++;
    print("NotificationService instance created: $_instanceCount");
    _init();
  }

  // 현재 위치를 가져오는 함수
  void _init() {
    print("_init called");
    String? _deviceId = _deviceInfo.getDeviceId();
    _webSocketService = WebSocketService(_backend_socket_server);
    _webSocketService.connect();
    // 클라이언트가 연결되면 자신의 ID를 서버에 전송
    print("[Socket]: $_deviceId 전송");
    _webSocketService.sendMessage(
        jsonEncode({'type': 'register', 'deviceId': _deviceId}));
    _webSocketService.messages.listen((message) {
      final decodedMessage = jsonDecode(message);
      // final decodedMessage = message;
      String notificationMsg = decodedMessage["message"];
      String locationId = decodedMessage["location_id"];
      String selectedDevice = decodedMessage["selected_device"];
      print("[Notification] Message Received from Socket Server!");
      // 여기에 로컬 알림을 띄우는 코드를 추가하세요.
      // Notification(locationId, notificationMsg, int.parse(locationId));
      if(_deviceId == selectedDevice){
        Notification(locationId, notificationMsg, int.parse(locationId));
      }
    });

    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5, // 위치가 5m 이상 변경되었을 때만 업데이트
        )
    ).listen((Position position) {
      String presentLatitude = position.latitude.toStringAsFixed(4);
      String presentLongitude = position.longitude.toStringAsFixed(4);
      if(previousLatitude == "" && previousLongitude == ""){
        previousLatitude = presentLatitude;
        previousLongitude = presentLongitude;
        _updateLocation(position, _deviceId);
      }else{
        if(previousLatitude != presentLatitude && previousLongitude != previousLongitude){
          _updateLocation(position, _deviceId);
        }
      }
    });
  }

  void _updateLocation(Position position, String deviceId) {
    // Redis에 위치 업데이트 로직 구현
    _redisClient.saveUserLocation(
        position.latitude.toDouble(), position.longitude.toDouble(), deviceId);
  }

  // 웹 소켓 연결 해제
  void dispose() {
    _webSocketService.disconnect();
  }

  Future Notification(String notiTitle, String notiDesc, int locationId) async {
    final result; //권한 확인을 위한 변수
    //----------------------------------------------------------------------------------
    //local notification 플러그인 객체 생성
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //플랫폼 확인해서 OS 종류에 따라 권한 확인
    //안드로이드 일때
    if (Platform.isAndroid) {
      result = true;
    }
    //IOS 일때
    else {
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
    var ios = IOSNotificationDetails(presentAlert: true,
        presentSound: true,
        presentBadge: true,
        badgeNumber: 1
    );
    //Notificaiton 옵션 값 등록
    var detail = NotificationDetails(android: android, iOS: ios);


    var initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: (id, title, body, payload) async {});
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    //----------------------------------------------------------------------------------
    //권한이 있으면 실행.
    if (result == true) {
      print("권한 확인, Notification 실행");
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: (String? payload) async {
            if (payload != null) {
              _navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => AboutThisPlace(locationId: int.parse(payload),)));
            }
          });
      await flutterLocalNotificationsPlugin.show(
          0, "정보 업데이트 발생!", notiDesc, detail, payload: locationId.toString());
    }
  }
}
