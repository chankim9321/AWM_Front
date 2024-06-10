import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ModifyScreen extends StatefulWidget {
  const ModifyScreen({super.key, required this.locationId});

  final int locationId;
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  quill.QuillController? _controller;
  String? token;
  int currentPage = 0;

  void _setToken() async {
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

  Future<void> _saveDocument() async {
    if (_controller == null) return;
    final String plainText = _controller!.document.toPlainText();
    try {
      final response = await http.post(
        Uri.parse('http://${ServerConf.url}/comm/user/log/save/${widget.locationId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
        },
        body: jsonEncode({'content': plainText}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('성공적으로 등록 되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록에 실패했습니다.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '정보 업데이트',
          style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white,),
            onPressed: _resetDocument,
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: _saveDocument,
          ),
        ],
      ),
      body: _controller == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: quill.QuillProvider(
            configurations: quill.QuillConfigurations(
              controller: _controller!,
              sharedConfigurations: const quill.QuillSharedConfigurations(
                locale: Locale('en'),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    // borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                  child: quill.QuillToolbar(
                    configurations: quill.QuillToolbarConfigurations(
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(
                        imageButtonOptions: QuillToolbarImageButtonOptions(),
                      ),
                    ),
                  ),
                ),
                // Divider(
                //   height: 1,
                //   color: Colors.grey,
                //   thickness: 1,
                // ),
                Expanded(
                  child: quill.QuillEditor.basic(
                    configurations: quill.QuillEditorConfigurations(
                      padding: const EdgeInsets.all(16),
                      embedBuilders: kIsWeb
                          ? FlutterQuillEmbeds.editorWebBuilders()
                          : FlutterQuillEmbeds.editorBuilders(),
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
        ),
      ),
    );
  }
}
