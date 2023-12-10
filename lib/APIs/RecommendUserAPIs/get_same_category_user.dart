import 'dart:convert';
import 'dart:typed_data';

import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/components/customDialog.dart';

class GetSameCategoryUser{
  static getSameCategoryUser() async {
    String? token = await SecureStorage().readSecureData('token');
    final response = await http.get(
      Uri.parse("http://${ServerConf.url}/user/search/similar-user"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token!
      },
    );
    if(response.statusCode == 200){
      List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonData.length);
      return jsonData;
    }
  }
}