import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/user_info.dart';


Future<bool> modifyPost(String title, String content, String imagePath, String authToken, int postId) async {

  final Uri endpoint = Uri.parse('http://${ServerConf.url}/user/update/$postId'); // 글 수정 api 주소 수정

  // Read JSON file containing title and content
  final Map<String, dynamic> postData = {
    'boardTitle': title,
    'boardContent': content,
    'boardWriter': UserInfo.userNickname,
  };

  // Create a multipart request
  final http.MultipartRequest request = http.MultipartRequest('POST', endpoint);
  request.headers['Authorization'] = authToken;
  // Add JSON file part
  request.files.add(http.MultipartFile.fromString(
    'dto', // Assuming your backend expects 'dto' as the key for the JSON file
    jsonEncode(postData),
    contentType: MediaType('application', 'json'),
  ));

  // Add image file part
  if (imagePath.isNotEmpty) {
    final File imageFile = File(imagePath);
    request.files.add(http.MultipartFile.fromBytes(
      'file', // Assuming your backend expects 'file' as the key for the image file
      await imageFile.readAsBytes(),
      filename: 'file',
      contentType: MediaType('image', 'jpeg'), // Adjust the content type based on your file type
    ));
  }

  // Send the request
  try {
    final http.Response response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      print('Post created successfully');
      return true;
    } else {
      print('Failed to create post: ${response.statusCode}');
      return false;
    }
  } catch (error) {
    print('Error creating post: $error');
    return false;
  }
}
