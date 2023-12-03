import 'dart:convert';

import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;

class LocationRegister{
  static postLocation(double latitude, double longitude, String category, String name) async {
    String? token = await SecureStorage().readSecureData("token");
    var response = http.post(
        Uri.parse("http://${ServerConf.url}/user/location/register"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        body: jsonEncode({
          "latitude" : latitude,
          "longitude" : longitude,
          "category" : category,
        })
    );
  }
}