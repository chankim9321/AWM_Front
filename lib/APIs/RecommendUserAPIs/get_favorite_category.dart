import 'dart:convert';
import 'dart:typed_data';

import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/components/customDialog.dart';

class GetFavoriteCategory{
  static getFavoriteCategory(List<String> recommendKeyword) async{
    String? token = await SecureStorage().readSecureData('token');
    String categorySerialized = recommendKeyword.join(",");
    final response = await http.post(
      Uri.parse("http://${ServerConf.url}/user/edit/category-list"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token!
      },
      body: jsonEncode({
        "categoryList": categorySerialized
      })
    );
    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
  }
}