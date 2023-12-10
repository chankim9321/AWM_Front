import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapdesign_flutter/APIs/PostAPIs/load_post_api.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/APIs/PostAPIs/post_modify_api.dart';
import 'package:mapdesign_flutter/user_info.dart';

String baseUrl = ServerConf.url;

class PostModifyScreen extends StatefulWidget {
  const PostModifyScreen({super.key, required this.postId});
  final int postId;
  @override
  _PostModifyScreenState createState() => _PostModifyScreenState();
}

class _PostModifyScreenState extends State<PostModifyScreen> {
  String tempFilePath = 'asset/img/temp_file.jpeg';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? imageFile;
  late final String? token;

  Future<void> _setToken() async{
    token = await SecureStorage().readSecureData('token');
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
  Future<void> _initPostInfo() async{
    PostDetail postInfo = await fetchPostDetail(widget.postId);
    titleController.text = postInfo.boardDto.boardContent;
    contentController.text = postInfo.boardDto.boardContent;
    // if(postInfo.boardDto.image != null){
    //   Uint8List bytes = base64.decode(postInfo.boardDto.image!);
    //   File file = File(tempFilePath); // 임시 파일 저장
    //   await file.writeAsBytes(bytes); // 파일 쓰기
    //   imageFile = file; // 바인딩
    // }
  }
  Future<void> _init() async{
    await _setToken();
    await _initPostInfo();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('글 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onPressed: () async {
                bool res = await modifyPost(titleController.text, contentController.text, imageFile?.path ?? '', token!, widget.postId);
                if(res){
                  CustomDialog.showCustomDialog(context, "등록 성공", "성공적으로 게시글이 수정되었습니다!");
                }else{
                  CustomDialog.showCustomDialog(context, "등록 실패", "게시글을 수정에 실패했습니다.");
                }
                Navigator.pop(context);
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

}
