import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ModifyScreen extends StatefulWidget {
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  quill.QuillController? _controller; // QuillController 인스턴스 선언

  @override
  void initState() {
    super.initState();
    _loadDocument(); // 초기화 시 문서 로드
  }

  // 문서를 리셋하는 메서드
  void _resetDocument() {
    setState(() {
      _controller = quill.QuillController.basic();
    });
  }

  // SharedPreferences에서 문서를 로드하는 비동기 메서드
  Future<void> _loadDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedJson = prefs.getString('saved_document');

    if (savedJson != null) {
      final decodedJson = jsonDecode(savedJson);
      final document = quill.Document.fromJson(decodedJson);
      _controller = quill.QuillController(document: document, selection: TextSelection.collapsed(offset: 0));
    } else {
      _controller = quill.QuillController.basic();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Text'),
        actions: [
          // 리셋 및 저장 버튼 추가
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetDocument,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDocument,
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
                  configurations:  quill.QuillEditorConfigurations(
                    padding: const EdgeInsets.all(16),
                    embedBuilders: kIsWeb ? FlutterQuillEmbeds.editorWebBuilders() : FlutterQuillEmbeds.editorBuilders(),
                    readOnly: false,
                    scrollable: true,
                    expands: false,
                    autoFocus: false,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 문서를 저장하는 메서드
  void _saveDocument() async {
    if (_controller == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String json = jsonEncode(_controller!.document.toDelta().toJson());
    await prefs.setString('saved_document', json);
    print('Saved Document: $json');
  }
}