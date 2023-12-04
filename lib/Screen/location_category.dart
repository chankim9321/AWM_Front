import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/Screen/locationRegister/location_write_page.dart';
import 'package:mapdesign_flutter/app_colors.dart';


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
  final List<String> categoryKey = [
    "도서관", "음식점", "자전거", "공원",
    "명소", "카페", "운동", "학교",
    "주차장", "흡연장", "쓰레기통", "편의점",
    "정류장", "약국", "프린트","기타"
  ];
  final List<Map<String, Icon>> categoryList = [
    {"도서관" : Icon(Icons.menu_book, semanticLabel: "도서관",)},
    {"음식점" : Icon(Icons.restaurant)},
    {"자전거" : Icon(Icons.directions_bike)},
    {"공원" : Icon(Icons.nature_people)},
    {"명소" : Icon(Icons.attractions)},
    {"카페" : Icon(Icons.local_cafe)},
    {"운동" : Icon(Icons.directions_run)},
    {"학교" : Icon(Icons.school)},
    {"주차장" : Icon(Icons.local_parking)},
    {"흡연장" : Icon(Icons.smoking_rooms)},
    {"쓰레기통" : Icon(Icons.delete)},
    {"편의점" : Icon(Icons.local_convenience_store)},
    {"정류장" : Icon(Icons.bus_alert_rounded)},
    {"프린트" : Icon(Icons.print)},
    {"약국" : Icon(Icons.medical_services)},
    {"기타" : Icon(Icons.not_listed_location)},
  ];


  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // Number of columns
          crossAxisSpacing: 10.0, // Horizontal space between items
          mainAxisSpacing: 10.0, // Vertical space between items
        ),
        itemCount: categoryList.length,
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
                              mapCategoryName: categoryList[index].keys.first,
                              latitude: widget.latitude,
                              longitude: widget.longitude,
                          ) // 글 쓰는 페이지로 이동
                      )
                    )
                  },
                  icon: categoryList[index].values.first
                ),
                Text(categoryList[index].keys.first)
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