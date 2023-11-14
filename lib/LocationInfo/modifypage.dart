import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ModifyScreen extends StatefulWidget {
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  quill.QuillController _controller = quill.QuillController.basic();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Text'),
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _pickImage,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveDocument,
          ),
        ],
      ),
      body: quill.QuillProvider(
        configurations: quill.QuillConfigurations(
          controller: _controller,
          sharedConfigurations: const quill.QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
        child: Column(
          children: [
            const quill.QuillToolbar(),
            Expanded(
              child: quill.QuillEditor.basic(
                configurations: const quill.QuillEditorConfigurations(
                  readOnly: false,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 이미지를 선택하고 에디터에 삽입하는 함수
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 이미지를 서버에 업로드하고 URL을 받아야 합니다.
      // 예제에서는 서버 업로드 대신 이미지의 로컬 경로를 사용합니다.
      final String imageUrl = image.path;

      // 에디터에 이미지 삽입
      final index = _controller.selection.baseOffset;
      final length = _controller.selection.extentOffset;
      _controller.replaceText(index, length, quill.BlockEmbed.image(imageUrl), null);
    }
  }

  // 문서를 JSON 형식으로 변환하여 저장하는 함수
  void _saveDocument() {
    final String json = jsonEncode(_controller.document.toDelta().toJson());
    // JSON 데이터를 저장하는 로직 구현
    // 예시로 콘솔에 출력, 실제로는 파일 시스템, 데이터베이스, 서버 등에 저장할 수 있음
    print('Saved Document: $json');
  }
}
