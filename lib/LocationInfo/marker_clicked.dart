import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_clicked.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_detailed.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'place_info.dart';
import 'dart:convert';
import 'dart:typed_data';

class MarkerClicked extends StatefulWidget {
  const MarkerClicked({super.key, required this.latitude, required this.longitude, required this.category});
  final double longitude;
  final double latitude;
  final String category;
  @override
  _MarkerClickedState createState() => _MarkerClickedState();
}

class _MarkerClickedState extends State<MarkerClicked> {
  // List<String> imagePaths = [
  //   'asset/img/tower_image.jpeg',
  //   'asset/img/test_1.webp',
  //   'asset/img/test_2.webp',
  //   'asset/img/test_3.jpeg',
  //   'asset/img/test_4.jpg',
  //   'asset/img/test_5.jpg',
  //   'asset/img/test_6.jpg',
  // ];
  List<Uint8List> imagePaths = [];
  String title = '';
  String mainImagePath = 'asset/img/tower_image.jpeg';
  int currentPage = 0;
  final double imageWidth = 60.0; // 이미지 너비
  final double imageHeight = 60.0; // 이미지 높이
  final double padding = 8.0; // 패딩

  void _loadImages() async {
    var locationData = await LocationClicked.clickLocation(widget.latitude, widget.longitude, widget.category);
    setState(() {
      title = locationData['title'];
      imagePaths = locationData['images'];
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadImages();
  }
  @override
  Widget build(BuildContext context) {
    // 디바이스 너비 계산
    final deviceWidth = MediaQuery.of(context).size.width;

    // 표시할 수 있는 이미지의 최대 개수 계산
    int maxImages = (deviceWidth / (imageWidth + padding * 2)).floor();
    if (maxImages > imagePaths.length) {
      maxImages = imagePaths.length;
    }
    return Scaffold(
      // backgroundColor: Colors.red,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(top: 15.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back, size: 40.0),
            color: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
      ),
      body: PageView.builder(
        itemCount: imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(imagePaths[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Container(
              //   color: Colors.black.withOpacity(0.5),
              // ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.0),
                        Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < maxImages-1; i++)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.memory(
                                    imagePaths[(i + currentPage) % imagePaths.length],
                                    width: imageWidth,
                                    height: imageHeight,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            if (imagePaths.length > maxImages)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    width: imageWidth,
                                    height: imageHeight,
                                    color: Colors.grey,
                                    child: Center(
                                      child: Text(
                                        '+${imagePaths.length - maxImages}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        SafeArea(
                          child: Container(
                            margin: EdgeInsets.only(left: 15.0, bottom: 20.0),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.85),
                                  minimumSize: Size(50.0, 60.0),
                                  shape: StadiumBorder(),
                                ),
                                onPressed: () async {
                                  int locationId = await LocationDetailed.locationDetailedClick(
                                      widget.latitude,
                                      widget.longitude,
                                      widget.category,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(locationId: locationId, imagePaths: imagePaths))
                                    );
                                },
                                icon: Icon(
                                  Icons.arrow_right_alt,
                                  color: Colors.black,
                                  size: 40.0,
                                ),
                                label: Text(
                                  "More Detailed Here!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 17.0
                                  ),
                                ),
                              )
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  // void _openDetailScreen() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => DetailScreen(),
  //     ),
  //   );
  // }
}