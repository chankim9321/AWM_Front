import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/RecommendUserAPIs/get_favorite_category.dart';
import 'package:mapdesign_flutter/Screen/category_list.dart';
import 'package:mapdesign_flutter/Screen/location_category_selection_page.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

class CategorySelector extends StatefulWidget {
  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final List<Map<String, Icon>> categoryList = CategoryList.categoryList;

  List<String> selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Your Category',
          style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(2.0, 2.0),
                ),
              ]
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  String key = categoryList[index].keys.first;
                  Icon icon = categoryList[index][key]!;
                  bool isSelected = selectedCategories.contains(key);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategories.remove(key);
                        } else {
                          selectedCategories.add(key); // 올바른 키 값을 추가합니다.
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.lightBlueAccent.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: Offset(4, 4),
                          )
                        ]
                            : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(2, 2),
                          ),
                        ],
                        gradient: isSelected
                            ? LinearGradient(
                          colors: [Colors.blue, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : LinearGradient(
                          colors: [Colors.white, Colors.grey[200]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          SizedBox(height: 8),
                          Text(
                            key,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 16.0, right: 16.0, bottom: 16.0),
            child: ElevatedButton(
              onPressed: () async {
                print(selectedCategories);
                bool res = await GetFavoriteCategory.getFavoriteCategory(
                    selectedCategories.map((category) => LocationCategoryPath.categoryToEng[category]!).toList()); // API에 전달할 때 변환
                if (res) {
                  CustomDialog.showCustomDialog(context, "카테고리 등록", "선호하는 카테고리 등록되었습니다.");
                } else {
                  CustomDialog.showCustomDialog(context, "카테고리 등록", "선호하는 카테고리 등록에 실패했습니다.");
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 150, vertical: 10),
                textStyle: TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
              child: Text(
                'Enter',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(2.0, 2.0),
                      ),
                    ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
