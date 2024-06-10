import 'dart:convert';
import 'dart:typed_data';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:http/http.dart' as http;

class LocationClicked{
  static clickLocation(double latitude, double longitude, String category) async {
    final response = await http.get(
        Uri.parse("http://${ServerConf.url}/loc/location/search/information?latitude=$latitude&longitude=$longitude&category=$category"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        }
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      String title = data["title"];
      List<dynamic> imageBlobs = data["images"];
      // Blob 데이터를 Uint8List로 변환합니다.
      List<Uint8List> images = imageBlobs.map<Uint8List>((imageData) {
        return base64Decode(imageData["image"]);
      }).toList();
      // 결과를 title과 이미지 리스트로 반환합니다.
      return {
        "title": title,
        "images": images
      };
    } else {
      // 오류 처리
      // throw Exception("Failed to load location data");
      return null;
    }
  }
}