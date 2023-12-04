import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.locationId});
  final int locationId;

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Expanded(
                child: TextField(
                  controller: _textEditingController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요',
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none
                    ),
                  ),
                ),
            ),
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _textEditingController.clear();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 검색 동작을 수행하세요.
              },
            ),
          ],
        ),
      ),
    );
  }
}
