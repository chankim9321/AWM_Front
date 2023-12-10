import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/user_info.dart';


Future<bool> removePost(int postId, String token) async {
  const String url = ServerConf.url;
  final response = await http.get(
    Uri.parse('http://$url/user/remove/$postId'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization' : token,
    }
  );
  if(response.statusCode == 200){
    return true;
  }else{
    return false;
  }
}
