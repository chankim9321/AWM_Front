import 'dart:convert';
import 'dart:typed_data';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;

class LocationDetailed{
  static locationDetailedClick(double latitude, double longitude, String category) async {
    final response = await http.get(
        Uri.parse("http://${ServerConf.url}/loc/location/search/get-location-id?latitude=$latitude&longitude=$longitude&category=$category"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        }
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      int locationId = data["locationId"];
      return locationId;
    } else {
      // 오류 처리
      throw Exception("Failed to load location data");
    }
  }
}