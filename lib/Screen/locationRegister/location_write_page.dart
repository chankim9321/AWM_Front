
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mapdesign_flutter/Screen/locationRegister/location_writer_form.dart';
import 'package:mapdesign_flutter/app_colors.dart';


class LocationWritePage extends StatefulWidget {
  const LocationWritePage({super.key, required this.mapCategoryName});
  final String mapCategoryName;
  @override
  State<LocationWritePage> createState() => _LocationWritePageState();
}

class _LocationWritePageState extends State<LocationWritePage> {
  XFile? _image;
  final quill.QuillController _quillController = quill.QuillController.basic();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);

    if(pickedFile != null){
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }
  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            width: double.infinity,
            height: 300,
            child: Image.file(File(_image!.path)), //가져온 이미지를 화면에 띄워주는 코드
          )
        : Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            width: double.infinity,
            height: 300,
            color: Colors.grey,
          );
  }
  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ElevatedButton(
        //   onPressed: () {
        //     getImage(ImageSource.camera); //getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
        //   },
        //   child: Text("카메라"),
        // ),
        // SizedBox(width: 30),

        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery); //getImage 함수를 호출해서 갤러리에서 사진 가져오기
          },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(400, 50),
              shape: StadiumBorder(),
              backgroundColor: AppColors.instance.skyBlue,
            ),
          child: const Row(
            children: [
              Icon(Icons.camera_alt_outlined),
              Text(" 앨범에서 가져오기")
            ],
          )
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("모두의 장소 등록"),
            backgroundColor: AppColors.instance.skyBlue,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 20.0,
              ),
              // 사진 추가
              _buildPhotoArea(),
              SizedBox(
                width: double.infinity,
                height: 20.0,
              ),
              _buildButton(),
              // 지명 입력
              Container(
                margin: EdgeInsets.only(
                    top: 30.0, right: 10.0, left: 10.0, bottom: 10.0),
                width: double.infinity,
                child: TextField(
                  controller: _textController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "장소의 이름을 입력하세요!",
                  ),
                  autofocus: true,
                ),
              ),
              // 설명창 추가

              SingleChildScrollView(
                child: SafeArea(
                  minimum: EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SafeArea(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.instance.skyBlue,
                                minimumSize: Size(double.infinity, 200)
                            ),
                            onPressed: () => {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => LocationWriterForm(controller: _quillController))
                              )
                            },
                            icon: Icon(Icons.edit_note),
                            label: Text("모두에게 공유하고 싶은 정보를 입력하세요!"),
                          )
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 10.0,
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () => {},
                        icon: Icon(Icons.share_location),
                        label: Text("등록"),
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        )
    );
  }
}
