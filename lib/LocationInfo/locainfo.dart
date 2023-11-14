import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    'asset/img/bombom.jpg',
    'asset/img/dridri.jpg',
    'asset/img/drinking.jpg',
    'asset/img/ddrink.jpg',
    'asset/img/boom.jpg',
    'asset/img/boomenu.jpg',
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModifyScreen(),
                ),
              );
            },
            icon: Icon(Icons.border_color),
            color: Colors.black,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CarouselSlider.builder(
            itemCount: imagePaths.length,
            options: CarouselOptions(
              height: 409.0,
              aspectRatio: 1.2,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  currentPage = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final path = imagePaths[index];
              return Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    height: 409.0,
                    width: 330.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        path,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.0,
                    bottom: 16.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            '봄봄',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            '대구시 게대동문',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < imagePaths.length; i++)
                Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == currentPage ? Colors.blue : Colors.grey,
                  ),
                ),
            ],
          ),
          // 이미지 밑에 추가 텍스트 및 아이콘들
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRoundedIcon(Icons.list_alt, AppColors.instance.whiteGrey, AppColors.instance.skyBlue),
                    _buildRoundedIcon(Icons.sync_alt, AppColors.instance.whiteGrey, AppColors.instance.skyBlue),
                    _buildRoundedIcon(Icons.chat_bubble, AppColors.instance.whiteGrey, AppColors.instance.skyBlue),
                    _buildRoundedIcon(Icons.forum, AppColors.instance.whiteGrey, AppColors.instance.skyBlue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedIcon(IconData icon, Color backgroundColor, Color iconColor) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: GestureDetector(
        // onTap: Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>  PostDetailScreen(),
        //     )
        // ),
        child: Center(
          child: Icon(
            icon,
            size: 32.0,
            color: iconColor,
          ),
        ),
      )
    );
  }
}