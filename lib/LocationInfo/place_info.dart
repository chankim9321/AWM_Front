import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/LocationInfo/place_component/sns_ui_heart_icon_screen.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/community/content.dart';
import 'modifypage.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final List<String> imagePaths = [
    'asset/img/tower_image.jpeg',
    'asset/img/test_1.webp',
    'asset/img/test_2.webp',
    'asset/img/test_3.jpeg',
    'asset/img/test_4.jpg',
    'asset/img/test_5.jpg',
    'asset/img/test_6.jpg',
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
              itemCount: imagePaths.length,
              options: CarouselOptions(
                height: screenHeight * 0.35, // Adjust the image height
                viewportFraction: 0.8,
                enlargeCenterPage: true,
                autoPlay: true,
              ),
              itemBuilder: (context, index, realIndex) {
                final imagePath = imagePaths[index];
                return Container(
                  width: screenWidth * 0.85, // Adjust the image width
                  height: 200.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
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
            SizedBox(height: screenHeight * 0.1), // Adjust bottom space
            Container(
              margin: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => {},
                    icon: Icon(
                        Icons.info_outlined
                    ),
                    label: Text(
                        ""
                    ),
                  )
                ],
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