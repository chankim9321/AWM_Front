import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class ModifyScreen extends StatefulWidget {
  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  File? _image; // 업로드한 이미지를 저장할 변수

  Future<void> _getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('수정하기'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _getImage, // 이미지 업로드 버튼
                      child: Text('이미지 업로드'),
                    ),
                    SizedBox(height: 20.0),
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('장소 이름'),
                            ),
                            TableCell(
                              child: TextFormField(
                                decoration: InputDecoration(border: OutlineInputBorder()),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('장소 주소'),
                            ),
                            TableCell(
                              child: TextFormField(
                                decoration: InputDecoration(border: OutlineInputBorder()),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('장소 정보'),
                            ),
                            TableCell(
                              child: TextFormField(
                                decoration: InputDecoration(border: OutlineInputBorder()),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('장소 의견'),
                            ),
                            TableCell(
                              child: TextFormField(
                                decoration: InputDecoration(border: OutlineInputBorder()),
                                keyboardType: TextInputType.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}