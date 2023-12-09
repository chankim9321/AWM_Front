import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ModifyScreen extends StatefulWidget {
  const ModifyScreen({super.key, required this.locationId});

  final int locationId;
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  quill.QuillController? _controller;
  String? token;
  int currentPage = 0;  // 페이지 번호를 저장할 변수 추가

  void _setToken() async{
    token = await SecureStorage().readSecureData('token');
  }
  @override
  void initState() {
    super.initState();
    _resetDocument();
    _setToken();
  }

  void _resetDocument() {
    setState(() {
      _controller = quill.QuillController.basic();
    });
  }
  /*Future<void> _fetchDataFromBackend() async { //토큰없이도 볼 수 있음 , 무슨내용 썻는지 확인용 수정은 아직 안됨
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
*/
  Future<void> _saveDocument() async {
    if (_controller == null) return;
    final String plainText = _controller!.document.toPlainText();
    try {
      print(plainText);
      print(token);
      print('http://${ServerConf.url}/user/log/save/${widget.locationId}');
      final response = await http.post(
        Uri.parse('http://${ServerConf.url}/user/log/save/${widget.locationId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,//토큰 가지고 있어야 함
        },
        body: jsonEncode({'content': plainText}),
      );
      if (response.statusCode == 200) {
        print('문서가 성공적으로 업데이트되었습니다.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('성공적으로 등록 되었습니다.')),
        );
      } else {
        print('API 호출 실패: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록에 실패했습니다.')),
        );
      }
    } catch (error) {
      print('API 호출 에러: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록에 실패했습니다.')),
      );
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
          /*IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: _fetchDataFromBackend,
          ),*/
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