import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/Screen/locationRegister/location_write_page.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/Screen/category_list.dart';

class LocationCategorySelectionPage extends StatefulWidget {
  const LocationCategorySelectionPage({
    super.key,
    required this.latitude,
    required this.longitude
  });

  final double latitude;
  final double longitude;
  @override
  State<LocationCategorySelectionPage> createState() => _LocationCategorySelectionPageState();
}

class _LocationCategorySelectionPageState extends State<LocationCategorySelectionPage> {
  @override
  Color iconColor = AppColors.instance.skyBlue;
  Color backgroundColor = AppColors.instance.whiteGrey;
  var categoryChanger = LocationCategoryPath();

  Widget build(BuildContext context) {
    // print("latitude = ${widget.latitude}, longitude = ${widget.longitude}");
    return SafeArea(
      minimum: EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns
          crossAxisSpacing: 10.0, // Horizontal space between items
          mainAxisSpacing: 10.0, // Vertical space between items
        ),
        itemCount: CategoryList.categoryList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocationWritePage(
                              mapCategoryName: CategoryList.categoryList[index].keys.first,
                              latitude: widget.latitude,
                              longitude: widget.longitude,
                          ) // 글 쓰는 페이지로 이동
                      )
                    )
                  },
                  icon: CategoryList.categoryList[index].values.first
                ),
                Text(CategoryList.categoryList[index].keys.first)
              ],
            )
          );
        },
      )
    );
  }
}
class LocationCategoryPath {
  static const String path = "asset/markers/";
  static const Map<String, String> categoryPath = {
    "library" : "${path}library.png",
    "restaurant" : "${path}restaurant.png",
    "bicycle" : "${path}bike.png",
    "pakr" : "${path}park.png",
    "hotspot" : "${path}amusement.png",
    "cafe" : "${path}cafe.png",
    "sports" : "${path}run.png",
    "school" : "${path}school.png",
    "parking" : "${path}parking.png",
    "smoking" : "${path}smoking.png",
    "trashcan" : "${path}bin.png",
    "convenience" : "${path}convenience.png",
    "bus" : "${path}busstop.png",
    "print" : "${path}print.png",
    "drugstore" : "${path}medical.png",
    "others" : "${path}unknown.png",
  };
  static const Map<String, String> categoryToEng = {
    "도서관" : "library",
    "음식점" : "restaurant",
    "자전거" : "bicycle",
    "공원" : "park",
    "명소" : "hotspot",
    "카페" : "cafe",
    "운동" : "sports",
    "학교" : "school",
    "주차장" : "parking",
    "흡연장" : "smoking",
    "쓰레기통" : "trashcan",
    "편의점" : "convenience",
    "정류장" : "bus",
    "프린트" : "print",
    "약국" : "drugstore",
    "기타" : "others",
  };
}