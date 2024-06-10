import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:mapdesign_flutter/APIs/backend_server.dart';

class LocationRecommend{
  static recommendLocation(int locationId) async{
    final response = await http.post(
        Uri.parse("http://${ServerConf.url}/loc/location/search/recommend-quick"),
        headers: <String, String> {
          'Content-Type':'application/json'
        },
        body: jsonEncode({
          "locationId" : locationId,
        })
    );
    if(response.statusCode != 200){
      print("AI기반 장소추천 에러: ${response.statusCode}");
      return null;
    }else{
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
  }
}