import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

String baseUrl = ServerConf.url;

Future<void> createPost(String title, String content, String imagePath, String authToken, int locationId) async {
  final Uri endpoint = Uri.parse('http://$baseUrl/user/board/save/$locationId'); // Replace with your actual backend endpoint

  // Read JSON file containing title and content
  final Map<String, dynamic> postData = {
    'boardTitle': title,
    'boardContent': content,
    'boardWriter': 'Lee',
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
    } else {
      print('Failed to create post: ${response.statusCode}');
    }
  } catch (error) {
    print('Error creating post: $error');
  }
}

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({super.key, required this.locationId});
  final int locationId;
  @override
  _PostCreationScreenState createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? imageFile;
  late final String? token;

  void _setToken() async{
    token = await SecureStorage().readSecureData('token');
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setToken();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글쓰기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /*TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),*/
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
            ),

            SizedBox(height: 16),
            if (imageFile != null)
              Image.file(
                imageFile!,
                width: 200,
                height: 200,
              ),
            /*ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: Text('Pick Image'),
            ),*/
            ElevatedButton(
              onPressed: pickImage,
              child: Text('이미지 선택'),
              style: ElevatedButton.styleFrom(
                //primary: Colors.transparent, // 버튼 색을 투명하게 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            /*TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),*/
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                createPost(titleController.text, contentController.text, imageFile?.path ?? '', token!, widget.locationId);
              },
              child: Text('등록하기'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }
}
