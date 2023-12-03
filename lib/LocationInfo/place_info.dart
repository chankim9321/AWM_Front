import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:mapdesign_flutter/LocationInfo/place_component/sns_ui_heart_icon_screen.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/community/content.dart';
import 'modifypage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'about_this_place.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.locationId, required this.imagePaths});
  final List<Uint8List> imagePaths;
  final int locationId;
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final List<Map<String, Icon>> buttonLabels = [
    {"About this place" : Icon(Icons.feed_outlined)},
    {"Commit Log" : Icon(Icons.checklist_rtl)},
    {"Chat" : Icon(Icons.chat)},
    {"Contributor" : Icon(Icons.military_tech)},
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.border_color),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModifyScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView to avoid pixel overflow
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.05), // Adjust top space
            CarouselSlider.builder(
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
            ),
            SizedBox(height: screenHeight * 0.05), // Space between the carousel and the text
            Text(
              'Place',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SnsUIHeartIconScreen(),
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
                  childAspectRatio: 1.5,
                ),
                itemCount: 4,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.instance.whiteGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () => {
                              if(index == 0){
                                 Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                         builder: (context) => about_this_place())
                                 )
                              }
                            },
                            icon: buttonLabels[index].values.first
                        ),
                        Text(buttonLabels[index].keys.first)
                      ],
                    )
                  );
                },
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.group),
      //       label: '커뮤니티',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.report),
      //       label: '신고',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.star),
      //       label: '즐겨찾기',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blue[400],
      //   onTap: _onItemTapped,
      // ),
    );
  }
}