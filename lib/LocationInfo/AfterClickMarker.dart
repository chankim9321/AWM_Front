import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'place_info.dart';

class LocalScreen extends StatefulWidget {
  const LocalScreen({super.key});
  @override
  _LocalScreenState createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen> {
  List<String> imagePaths = [
    'asset/img/tower_image.jpeg',
    'asset/img/test_1.webp',
    'asset/img/test_2.webp',
    'asset/img/test_3.jpeg',
    'asset/img/test_4.jpg',
    'asset/img/test_5.jpg',
    'asset/img/test_6.jpg',
  ];
  String mainImagePath = 'asset/img/tower_image.jpeg';
  int currentPage = 0;
  final double imageWidth = 60.0; // 이미지 너비
  final double imageHeight = 60.0; // 이미지 높이
  final double padding = 8.0; // 패딩


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
                    image: AssetImage(imagePaths[index]),
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
                            'Test View',
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20.0),
                          child: Text(
                            'this is test view.',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.normal,
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
                                  child: Image.asset(
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
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen())
                                    )
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

  void _openDetailScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(),
      ),
    );
  }
}