import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/user_info.dart';

String baseUrl = ServerConf.url;

Future<bool> createPost(String title, String content, String imagePath, String authToken, int locationId) async {
  final Uri endpoint = Uri.parse('http://$baseUrl/comm/user/board/save/$locationId');
  print(endpoint.path);

  final Map<String, dynamic> postData = {
    'boardTitle': title,
    'boardContent': content,
    'boardWriter': UserInfo.userNickname,
  };

  final http.MultipartRequest request = http.MultipartRequest('POST', endpoint);
  request.headers['Authorization'] = authToken;
  request.files.add(http.MultipartFile.fromString(
    'dto',
    jsonEncode(postData),
    contentType: MediaType('application', 'json'),
  ));

  if (imagePath.isNotEmpty) {
    final File imageFile = File(imagePath);
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      await imageFile.readAsBytes(),
      filename: 'file',
      contentType: MediaType('image', 'jpeg'),
    ));
  }

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

  void _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }

  @override
  void initState() {
    super.initState();
    _setToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글쓰기', style: TextStyle(fontSize: 20, fontFamily: 'PretendardLight', color: Colors.white),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(titleController, '제목을 입력하세요'),
            SizedBox(height: 16),
            if (imageFile != null) _buildImagePreview(imageFile!),
            SizedBox(height: 16),
            _buildGradientButton('이미지 선택', pickImage),
            SizedBox(height: 16),
            _buildTextField(contentController, '내용을 입력하세요', maxLines: 10),
            SizedBox(height: 16),
            _buildGradientButton('등록하기', () async {
              bool res = await createPost(
                titleController.text,
                contentController.text,
                imageFile?.path ?? '',
                token!,
                widget.locationId,
              );
              if (res) {
                CustomDialog.showCustomDialog(context, "등록 성공", "성공적으로 게시글이 등록되었습니다!");
              } else {
                CustomDialog.showCustomDialog(context, "등록 실패", "게시글을 등록에 실패했습니다.");
              }
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      keyboardType: TextInputType.multiline,
      maxLines: maxLines,
    );
  }

  Widget _buildImagePreview(File imageFile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.file(
          imageFile,
          width: 200,
          height: 200,
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0), // 가로 패딩 추가
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
          onSurface: Colors.grey,
        ).copyWith(
          elevation: MaterialStateProperty.all(5.0),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 12), // 세로 패딩만 적용
            child: Text(
              text,
              style: TextStyle(fontSize: 16, fontFamily: 'PretendardLight', color: Colors.white),
            ),
          ),
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
