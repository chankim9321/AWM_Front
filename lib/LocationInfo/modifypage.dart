import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ModifyScreen extends StatefulWidget {
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  quill.QuillController? _controller;
  //String jwtToken = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6InNldW5neWVvYnNpbkBnbWFpbC5jb20iLCJwcm92aWRlciI6Imdvb2dsZSIsIm5pY2tOYW1lIjoi7KCc65OcIiwicmFua1Njb3JlIjowLCJpYXQiOjE3MDE0MTE2NzksImV4cCI6MTcwMTQ1NDg3OX0.BES56xF3CMszdjI49zLBiU64X8XHJ5N8EWljtNa1f9E';//토큰은 직접입력했음
  String? jwtToken;
  final storage = FlutterSecureStorage();
  int currentPage = 0;  // 페이지 번호를 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    _resetDocument();
    _loadJwtToken();
  }

  void _resetDocument() {
    setState(() {
      _controller = quill.QuillController.basic();
    });
  }

  Future<void> _loadJwtToken() async {
    try {
      final String? token = await storage.read(key: 'jwt_token');
      //final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        jwtToken = token ?? jwtToken;
        //jwtToken = prefs.getString('jwt_token') ?? jwtToken;           //토큰저장하는거 securestorage로 변경해야함
      });
    } catch (e){
      print('토큰 불러오기 오류');      //안될수 catch에 있는거 다 없애고 try랑 try의 괄호 없애기
    }
  }

  Future<void> _fetchDataFromBackend() async { //토큰없이도 볼 수 있음 , 무슨내용 썻는지 확인용 수정은 아직 안됨
    try {
      final response = await http.get(
        Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/log/paging/1?page=$currentPage'), //url만 붙이면 됨 ex:https://f42b-27-124-178-180.ngrok-free.app/log/paging/1?page=$currentPage
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        final logs = data['content'] as List;
        String combinedText = '';

        for (var log in logs) {
          final content = log['content'];

            combinedText += '$content\n\n\n';

        }

        _controller = quill.QuillController(
          document: quill.Document()..insert(0, combinedText),
          selection: TextSelection.collapsed(offset: 0),
        );

        setState(() {});
      } else {
        print('API 호출 실패: ${response.statusCode}');
      }

      currentPage++;
    } catch (error) {
      print('API 호출 에러: $error');
    }
  }




  Future<void> _saveDocument() async {          //저장하는 매소드, 이미지는 아직 안됨
    if (_controller == null) return;

    final String plainText = _controller!.document.toPlainText();

    try {
      final response = await http.post(
        Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/user/log/save/1'), //url 경로치기 ex):https://f42b-27-124-178-180.ngrok-free.app/user/log/save/1
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$jwtToken',//토큰 가지고 있어야 함
        },
        body: jsonEncode({'content': plainText}),
      );

      if (response.statusCode == 200) {
        print('문서가 성공적으로 업데이트되었습니다.');
      } else {
        print('API 호출 실패: ${response.statusCode}');
      }
    } catch (error) {
      print('API 호출 에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Text'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetDocument,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDocument,
          ),
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: _fetchDataFromBackend,
          ),
        ],
      ),
      body: _controller == null
          ? CircularProgressIndicator()
          : quill.QuillProvider(
        configurations: quill.QuillConfigurations(
          controller: _controller!,
          sharedConfigurations: const quill.QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
        child: Column(
          children: [
            quill.QuillToolbar(
              configurations: quill.QuillToolbarConfigurations(
                embedButtons: FlutterQuillEmbeds.toolbarButtons(
                  imageButtonOptions: QuillToolbarImageButtonOptions(),
                ),
              ),
            ),
            Expanded(
              child: quill.QuillEditor.basic(
                configurations: quill.QuillEditorConfigurations(
                  padding: const EdgeInsets.all(16),
                  embedBuilders:
                  kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
                  readOnly: false,
                  scrollable: true,
                  expands: false,
                  autoFocus: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
