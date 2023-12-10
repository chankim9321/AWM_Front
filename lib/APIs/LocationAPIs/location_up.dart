import 'dart:convert';
import 'dart:typed_data';

import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;

class LocationUp{
  static recommendLocation(int locationId, String name, Uint8List image) async {
    String? token = await SecureStorage().readSecureData("token");
    var response;
    if(image.isEmpty){
      response = http.post(
          Uri.parse("http://${ServerConf.url}/user/location/edit"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token!
          },
          body: jsonEncode({
            "locationId": locationId,
            "title": name,
          })
      );
    }else{
      response = http.post(
          Uri.parse("http://${ServerConf.url}/user/location/edit"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token!
          },
          body: jsonEncode({
            "locationId": locationId,
            "title": name,
            "image": base64Encode(image),
          })
      );
    }
  }
}