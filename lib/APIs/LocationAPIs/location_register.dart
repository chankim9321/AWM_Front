import 'dart:convert';
import 'dart:typed_data';

import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';

class LocationRegister{
  static postLocation(double latitude, double longitude, String category, String name, Uint8List image) async {
    String? token = await SecureStorage().readSecureData("token");
    http.Response response;
    if(image.isEmpty){
      print("이미지 없음");
      response = await http.post(
          Uri.parse("http://${ServerConf.url}/loc/user/location/register"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token!
          },
          body: jsonEncode({
            "latitude" : latitude,
            "longitude" : longitude,
            "category" : category,
            "title": name,
          })
      );
    }else{
      print("이미지 있음!");
      response = await http.post(
          Uri.parse("http://${ServerConf.url}/loc/user/location/register"),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': token!
          },
          body: jsonEncode({
            "latitude" : latitude,
            "longitude" : longitude,
            "category" : category,
            "title": name,
            "image": base64Encode(image),
          })
      );
      if(response.statusCode != 200){
        print("장소 등록 실패, 에러코드: ${response.statusCode}");
        throw Exception("Error");
      }
    }
  }
}