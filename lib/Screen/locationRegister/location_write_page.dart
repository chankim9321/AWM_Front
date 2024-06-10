import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_register.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';
import 'package:mapdesign_flutter/Screen/location_category_selection_page.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

class LocationWritePage extends StatefulWidget {
  const LocationWritePage({
    super.key,
    required this.mapCategoryName,
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
  final String mapCategoryName;

  @override
  State<LocationWritePage> createState() => _LocationWritePageState();
}

class _LocationWritePageState extends State<LocationWritePage> {
  XFile? _image;
  final TextEditingController _textController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  Uint8List imageBytes = Uint8List(0);
  final storage = SecureStorage();

  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    imageBytes = await pickedFile!.readAsBytes();
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 300,
      child: Image.file(File(_image!.path)), // 가져온 이미지를 화면에 띄워주는 코드
    )
        : Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 300,
      color: Colors.grey,
      child: Center(
        child: Text(
          '이미지를 선택하세요',
          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'PretendardThin'),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ElevatedButton(
        onPressed: () {
          getImage(ImageSource.gallery); // getImage 함수를 호출해서 갤러리에서 사진 가져오기
        },
        style: ElevatedButton.styleFrom(
          minimumSize: Size(MediaQuery.of(context).size.width - 20, 50), // 수정된 부분
          shape: StadiumBorder(),
          backgroundColor: AppColors.instance.skyBlue,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.white),
            Text(" 앨범에서 가져오기", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "모두의 장소 등록",
            style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'PretendardThin'),
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
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 20.0),
              // 사진 추가
              _buildPhotoArea(),
              SizedBox(height: 20.0),
              // 사진 등록 버튼
              _buildButton(),
              // 지명 입력
              Container(
                margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 10.0),
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
                    backgroundColor: AppColors.instance.skyBlue,
                  ),
                  onPressed: () async {
                    try {
                      await LocationRegister.postLocation(
                        widget.latitude,
                        widget.longitude,
                        LocationCategoryPath.categoryToEng[widget.mapCategoryName]!,
                        _textController.text,
                        imageBytes,
                      );
                      CustomDialog.showCustomDialog(context, "장소 등록", "장소 등록이 성공적으로 수행되었습니다! "
                          "여러 사람이 장소를 선택할 시 점수가 상승하며 일정 점수 이상 시 모든 유저에게 보이게 됩니다!");
                    } catch (e) {
                      CustomDialog.showCustomDialog(context, "장소 등록", "장소 등록에 실패했습니다!");
                    } finally {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MapScreen()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  },
                  icon: Icon(Icons.share_location, color: Colors.white),
                  label: Text("등록", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
