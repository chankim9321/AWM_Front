import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ModifyScreen extends StatefulWidget {
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  quill.QuillController? _controller;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

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
            const quill.QuillToolbar(),
            Expanded(
              child: quill.QuillEditor.basic(
                  configurations: const quill.QuillEditorConfigurations(
                    readOnly: false,
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final String imageUrl = image.path;

      final index = _controller!.selection.baseOffset;
      final length = _controller!.selection.extentOffset;
      _controller!.replaceText(index, length, quill.BlockEmbed.image(imageUrl), null);
    }
  }

  void _saveDocument() async {
    if (_controller == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String json = jsonEncode(_controller!.document.toDelta().toJson());
    await prefs.setString('saved_document', json);
    print('Saved Document: $json');
  }
}
