import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_clicked.dart';
import 'package:mapdesign_flutter/APIs/LocationAPIs/location_detailed.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'place_info.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:animated_icon/animated_icon.dart';

class MarkerClicked extends StatefulWidget {
  const MarkerClicked({super.key, required this.latitude, required this.longitude, required this.category});
  final double longitude;
  final double latitude;
  final String category;
  @override
  MarkerClickedState createState() => MarkerClickedState();
}

class MarkerClickedState extends State<MarkerClicked> {
  List<Uint8List> imagePaths = [];
  String title = '';
  String defaultImagePath = "asset/img/default_location.jpg";
  int currentPage = 0;
  final double imageWidth = 60.0; // 이미지 너비
  final double imageHeight = 60.0; // 이미지 높이
  final double padding = 8.0; // 패딩
  late ImageProvider image;

  Future<Uint8List> convertImageFileToUint8List(File imageFile) async {
    Uint8List uint8list = await imageFile.readAsBytes();
    return uint8list;
  }

  Future<void> _loadImages() async {
    var locationData = await LocationClicked.clickLocation(widget.latitude, widget.longitude, widget.category);
    try {
      imagePaths = locationData['images'];
      print("yes images");
      setState(() {
        title = locationData['title'];
        image = MemoryImage(locationData['images'][0]);
      });
    } catch (e) {
      print("no imagess..");
      var bytes = await rootBundle.load(defaultImagePath);
      imagePaths.add(bytes.buffer.asUint8List());
      setState(() {
        title = locationData['title'];
        image = MemoryImage(imagePaths[0]);
      });
    }
  }

  Future<void> _init() async {
    await _loadImages();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    int maxImages = (deviceWidth / (imageWidth + padding * 2)).floor();
    if (maxImages > imagePaths.length) {
      maxImages = imagePaths.length;
    }

    return Scaffold(
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
        ),
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
              AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: Container(
                  key: ValueKey<int>(currentPage),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imagePaths.isNotEmpty ? MemoryImage(imagePaths[currentPage]) : image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
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
                              shadows: const [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black,
                                  offset: Offset(3.0, 3.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < maxImages; i++)
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
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            margin: EdgeInsets.only(left: 15.0, bottom: 20.0, right: 15.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  minimumSize: Size(double.infinity, 60.0),
                                  shape: StadiumBorder(),
                                  elevation: 0,
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
                                      builder: (context) => DetailScreen(locationId: locationId, imagePaths: imagePaths, locationName: title),
                                    ),
                                  );
                                },
                                icon: AnimateIcon(
                                  color: Colors.lightBlueAccent,
                                  animateIcon: AnimateIcons.mapPointer,
                                  onTap: () {},
                                  iconType: IconType.continueAnimation,
                                ),
                                label: Text(
                                  "자세히 알아보기",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 17.0,
                                  ),
                                ),
                              ),
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
}
