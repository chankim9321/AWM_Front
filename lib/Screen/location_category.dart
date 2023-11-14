import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/app_colors.dart';


class LocationCategory extends StatefulWidget {
  const LocationCategory({super.key});

  @override
  State<LocationCategory> createState() => _LocationCategoryState();
}

class _LocationCategoryState extends State<LocationCategory> {
  @override
  Color iconColor = AppColors.instance.skyBlue;
  Color backgroundColor = AppColors.instance.whiteGrey;
  final List<Icon> categoryList = [
    Icon(Icons.menu_book),
    Icon(Icons.restaurant),
    Icon(Icons.directions_bike),
    Icon(Icons.nature_people),
    Icon(Icons.attractions),
    Icon(Icons.local_cafe),
    Icon(Icons.directions_run),
    Icon(Icons.school),
    Icon(Icons.local_parking),
    Icon(Icons.smoking_rooms),
    Icon(Icons.delete),
    Icon(Icons.local_convenience_store),
    Icon(Icons.not_listed_location)
  ];


  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns
        crossAxisSpacing: 4.0, // Horizontal space between items
        mainAxisSpacing: 4.0, // Vertical space between items
      ),
      itemCount: categoryList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            // Handle icon tap
            print("Icon tapped: ${categoryList[index]}");
          },
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: categoryList[index],
          ),
        );
      },
    );
  }
}
