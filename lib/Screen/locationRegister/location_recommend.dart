
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_register.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/Screen/home_screen.dart';
import 'package:mapdesign_flutter/Screen/locationRegister/location_writer_form.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_up.dart';


class LocationRecommend extends StatefulWidget {
  const LocationRecommend({
    super.key,
    required this.locationId,
    required this.locationName
  });
  final String locationName;
  final int locationId;
  @override
  State<LocationRecommend> createState() => _LocationRecommendState();
}

class _LocationRecommendState extends State<LocationRecommend> {
  XFile? _image;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  Uint8List imageBytes = Uint8List(0);
  final storage = SecureStorage();
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageBytes = await pickedFile!.readAsBytes();
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
        Container(
          margin: EdgeInsets.all(10.0),
          child: ElevatedButton(
              onPressed: () {
                getImage(ImageSource.gallery); //getImage 함수를 호출해서 갤러리에서 사진 가져오기
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width-20, 50), // 수정된 부분
                shape: StadiumBorder(),
                backgroundColor: AppColors.instance.skyBlue,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined),
                  Text(" 앨범에서 가져오기")
                ],
              )
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    _textController.text = widget.locationName;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("모두의 장소 추천"),
            backgroundColor: AppColors.instance.skyBlue,
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                // 사진 등록 버튼
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
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(double.infinity - 20, 50),
                    ),
                    onPressed: () {
                      try{
                        LocationUp.recommendLocation(widget.locationId, _textController.text, imageBytes);
                        CustomDialog.showCustomDialog(context, "장소 추천", "장소 추천이 성공적으로 수행되었습니다!");
                      }catch(e){
                        CustomDialog.showCustomDialog(context, "장소 추천", "장소 추천에 실패했습니다!");
                      }finally{
                        Navigator.pushAndRemoveUntil(
                            context, MaterialPageRoute(
                            builder: (context) => MapScreen()
                        ), (Route<dynamic> route) => false
                        );
                      }
                    },
                    icon: Icon(Icons.share_location),
                    label: Text("추천"),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}
