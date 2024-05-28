import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/Screen/locationRegister/location_write_page.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/Screen/category_list.dart';

class LocationCategory extends StatefulWidget {
  const LocationCategory({
    super.key,
    required this.latitude,
    required this.longitude
  });

  final double latitude;
  final double longitude;
  @override
  State<LocationCategory> createState() => _LocationCategoryState();
}

class _LocationCategoryState extends State<LocationCategory> {
  @override
  Color iconColor = AppColors.instance.skyBlue;
  Color backgroundColor = AppColors.instance.whiteGrey;

  Widget build(BuildContext context) {
    print("latitude = ${widget.latitude}, longitude = ${widget.longitude}");
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
    "도서관" : "${path}library.png",
    "음식점" : "${path}restaurant.png",
    "자전거" : "${path}bike.png",
    "공원" : "${path}park.png",
    "명소" : "${path}amusement.png",
    "카페" : "${path}cafe.png",
    "운동" : "${path}run.png",
    "학교" : "${path}school.png",
    "주차장" : "${path}parking.png",
    "흡연장" : "${path}smoking.png",
    "쓰레기통" : "${path}bin.png",
    "편의점" : "${path}convenience.png",
    "정류장" : "${path}busstop.png",
    "프린트" : "${path}print.png",
    "약국" : "${path}medical.png",
    "기타" : "${path}unknown.png",
  };
}