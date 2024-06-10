import 'dart:convert';
import 'dart:typed_data';

import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;

class LocationDown{
  static disapproveLocation(int locationId) async {
    String? token = await SecureStorage().readSecureData("token");
    var response = http.post(
        Uri.parse("http://${ServerConf.url}/loc/user/location/delete"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': token!
        },
        body: jsonEncode({
          "locationId": locationId,
        })
    );
  }
}