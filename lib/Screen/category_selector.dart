import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/APIs/RecommendUserAPIs/get_favorite_category.dart';
import 'package:mapdesign_flutter/Screen/category_list.dart';
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
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: categoryList.length,
            itemBuilder: (context, index) {
              String key = categoryList[index].keys.first;
              Icon icon = categoryList[index][key]!;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedCategories.contains(key)) {
                      selectedCategories.remove(key);
                    } else {
                      selectedCategories.add(key);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: selectedCategories.contains(key)
                        ? Border.all(color: Colors.blue, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      Text(key),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            print(selectedCategories);
            bool res = await GetFavoriteCategory.getFavoriteCategory(selectedCategories);
            if(res){
              CustomDialog.showCustomDialog(context, "카테고리 등록", "선호하는 카테고리 등록되었습니다.");
            }else{
              CustomDialog.showCustomDialog(context, "카테고리 등록", "선호하는 카테고리 등록에 실패했습니다.");
            }
            Navigator.pop(context);
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}
