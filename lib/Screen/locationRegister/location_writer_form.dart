import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocationWriterForm extends StatefulWidget {
  final quill.QuillController controller;
  const LocationWriterForm({super.key, required this.controller});
  @override
  _LocationWriterFormState createState() => _LocationWriterFormState();
}

class _LocationWriterFormState extends State<LocationWriterForm> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.instance.skyBlue,
        title: Text('Edit Text'),
        actions: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: quill.QuillProvider(
        configurations: quill.QuillConfigurations(
          controller: widget.controller!,
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

      final index = widget.controller!.selection.baseOffset;
      final length = widget.controller!.selection.extentOffset;
      widget.controller!.replaceText(index, length, quill.BlockEmbed.image(imageUrl), null);
    }
  }
}
