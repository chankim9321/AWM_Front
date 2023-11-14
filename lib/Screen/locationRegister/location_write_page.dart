import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class LocationWritePage extends StatefulWidget {
  const LocationWritePage({super.key, required this.mapCategoryName});
  final String mapCategoryName;
  @override
  State<LocationWritePage> createState() => _LocationWritePageState();
}

class _LocationWritePageState extends State<LocationWritePage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // 사진 추가

            // 지명 입력
            Container(
              margin: EdgeInsets.only(top: 30.0, right: 10.0, left: 10.0, bottom: 10.0),
              width: double.infinity,
              child: TextField(
                maxLength: 20,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "장소의 이름을 입력하세요.",
                ),
                autofocus: true,
              ),
            )
            // 설명창 추가
          ],
        ),
      )
    );
  }
}
