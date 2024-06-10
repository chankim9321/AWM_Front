import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/LocationInfo/LocationRecommendation/location_recommend_page.dart';
import 'dart:typed_data';
import 'package:mapdesign_flutter/LocationInfo/place_component/sns_ui_heart_icon_screen.dart';
import 'package:mapdesign_flutter/Screen/locationRegister/location_recommend.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_down.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/community/content.dart';
import 'package:mapdesign_flutter/user_info.dart';
import 'modify_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'about_this_place.dart';
import 'package:mapdesign_flutter/Screen/google_map_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/community/post_list_screen.dart';
import 'package:mapdesign_flutter/community/socket_chat.dart';
import 'recoomend_button.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen(
      {super.key,
        required this.locationId,
        required this.imagePaths,
        required this.locationName});

  final List<Uint8List> imagePaths;
  final int locationId;
  final String locationName;


  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final List<Map<String, Icon>> buttonLabels = [
    {"About this place": Icon(Icons.feed_outlined)},
    {"Community": Icon(Icons.checklist_rtl)},
    {"Chat": Icon(Icons.chat)},
    {"Contributor": Icon(Icons.military_tech)},
  ];
  int _selectedIndex = 0; // For the bottom navigation bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Here you can add your navigation or other actions
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          '장소 상세 정보',
          style: TextStyle(
            fontFamily: 'PretendardLight',
            color: Colors.white,
          ),
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
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.border_color),
            tooltip: "정보 갱신",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ModifyScreen(
                      locationId: widget.locationId,
                    )),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.thumb_up_alt_outlined),
            tooltip: "추천 또는 사진 갱신",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LocationRecommend(
                        locationId: widget.locationId,
                        locationName: widget.locationName)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.thumb_down_alt_outlined),
            tooltip: "비추천 또는 점수 감소",
            onPressed: () {
              try {
                LocationDown.disapproveLocation(widget.locationId);
                CustomDialog.showCustomDialog(context, "장소 비추천",
                    "장소 비추천이 성공적으로 수행되었습니다.");
              } catch (e) {
                CustomDialog.showCustomDialog(context, "장소 비추천",
                    "장소 비추천에 실패했습니다!");
              } finally {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapScreen()),
                        (Route<dynamic> route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.05), // Adjust top space
            widget.imagePaths.length != 0 ? CarouselSlider.builder(
              itemCount: widget.imagePaths.length,
              options: CarouselOptions(
                height: screenHeight * 0.35, // Adjust the image height
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              itemBuilder: (context, index, realIndex) {
                final imagePath = widget.imagePaths[index];
                return Container(
                  width: screenWidth * 0.85, // Adjust the image width
                  height: 200.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.memory(
                      imagePath,
                      fit: BoxFit.cover, // Use fitWidth to ensure the image is not cropped
                    ),
                  ),
                );
              },
            ):
            SizedBox(width: double.infinity, height: 200.0,),
            SizedBox(height: screenHeight * 0.02), // Space between the carousel and the text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.locationName,
                style: TextStyle(
                  fontSize: 28.0,
                  fontFamily: 'PretendardLight',
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.0),
            SnsUIHeartIconScreen(),
            SizedBox(height: 10.0), // Adjust bottom space
            RecommendButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => SimilarPlacesPage(locationId: widget.locationId)));
              },
            ),
            SizedBox(height: 10.0), // Adjust bottom space
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10.0, // Horizontal space between items
                  mainAxisSpacing: 10.0, // Vertical space between items
                  childAspectRatio: 1.2, // Adjusted aspect ratio for better appearance
                ),
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AboutThisPlace(
                                        locationId: widget.locationId)),
                              );
                            } else if (_selectedIndex == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogListScreen(
                                    locationId: widget.locationId,
                                  ),
                                ),
                              );
                            } else if (_selectedIndex == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    locationId: widget.locationId,
                                    nickName: UserInfo.userNickname,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: buttonLabels[index].values.first,
                          iconSize: 50, // Increase icon size
                          color: Colors.white,
                        ),
                        SizedBox(height: 10), // Add space between icon and text
                        Text(
                          buttonLabels[index].keys.first,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'PretendardThin',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
