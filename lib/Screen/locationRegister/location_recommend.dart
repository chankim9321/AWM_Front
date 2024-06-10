import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_register.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_up.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Image.file(File(_image!.path), fit: BoxFit.cover),
      ),
    )
        : Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Icon(
        Icons.photo,
        color: Colors.grey[700],
        size: 100,
      ),
    );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () {
              getImage(ImageSource.gallery);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.of(context).size.width - 20, 50),
              shape: StadiumBorder(),
              backgroundColor: Colors.blueAccent,
              shadowColor: Colors.purpleAccent,
              elevation: 5,
              textStyle: TextStyle(
                fontFamily: 'PretendardLight',
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white,),
                Text(" 앨범에서 가져오기", style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white),)
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _textController.text = widget.locationName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "모두의 장소 추천",
          style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            _buildPhotoArea(),
            SizedBox(height: 20.0),
            _buildButton(),
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
                style: TextStyle(
                  fontFamily: 'PretendardLight',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  minimumSize: Size(double.infinity - 20, 50),
                  backgroundColor: Colors.blueAccent,
                  shadowColor: Colors.purpleAccent,
                  elevation: 5,
                  textStyle: TextStyle(
                    fontFamily: 'PretendardLight',
                  ),
                ),
                onPressed: () {
                  try {
                    LocationUp.recommendLocation(
                        widget.locationId, _textController.text, imageBytes);
                    CustomDialog.showCustomDialog(
                        context, "장소 추천", "장소 추천이 성공적으로 수행되었습니다!");
                  } catch (e) {
                    CustomDialog.showCustomDialog(
                        context, "장소 추천", "장소 추천에 실패했습니다!");
                  } finally {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                          (Route<dynamic> route) => false,
                    );
                  }
                },
                icon: Icon(Icons.share_location, color: Colors.white,),
                label: Text("추천", style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
