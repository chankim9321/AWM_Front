import 'package:flutter/material.dart';

class CategoryList{
  static final List<String> categoryKey = [
    "도서관", "음식점", "자전거", "공원",
    "명소", "카페", "운동", "학교",
    "주차장", "흡연장", "쓰레기통", "편의점",
    "정류장", "약국", "프린트","기타"
  ];
  static final List<Map<String, Icon>> categoryList = [
    {"도서관" : Icon(Icons.menu_book, semanticLabel: "library",)},
    {"음식점" : Icon(Icons.restaurant, semanticLabel: "restaurant",)},
    {"자전거" : Icon(Icons.directions_bike, semanticLabel: "bicycle",)},
    {"공원" : Icon(Icons.nature_people, semanticLabel: "park",)},
    {"명소" : Icon(Icons.attractions, semanticLabel: "hotspot",)},
    {"카페" : Icon(Icons.local_cafe, semanticLabel: "cafe",)},
    {"운동" : Icon(Icons.directions_run, semanticLabel: "sports",)},
    {"학교" : Icon(Icons.school, semanticLabel: "school",)},
    {"주차장" : Icon(Icons.local_parking, semanticLabel: "parking",)},
    {"흡연장" : Icon(Icons.smoking_rooms, semanticLabel: "smoking",)},
    {"쓰레기통" : Icon(Icons.delete, semanticLabel: "trashcan",)},
    {"편의점" : Icon(Icons.local_convenience_store, semanticLabel: "convenience",)},
    {"정류장" : Icon(Icons.bus_alert_rounded, semanticLabel: "bus",)},
    {"프린트" : Icon(Icons.print, semanticLabel: "print",)},
    {"약국" : Icon(Icons.medical_services, semanticLabel: "drugstore",)},
    {"기타" : Icon(Icons.not_listed_location, semanticLabel: "others",)},
  ];
}