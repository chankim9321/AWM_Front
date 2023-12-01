import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class about_this_place extends StatefulWidget {
  @override
  _about_this_placeState createState() => _about_this_placeState();
}

class _about_this_placeState extends State<about_this_place> {
  int currentPage = 0;
  List<Map<String, String>> contentList = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromBackend();
  }

  Future<void> _fetchDataFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/log/paging/1?page=$currentPage'),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        final logs = data['content'] as List;

        for (var log in logs) {
          final nickName = log['nickName'];
          final content = log['content'];

          setState(() {
            contentList.add({'nickName': nickName, 'content': content});
          });
        }
      } else {
        print('API 호출 실패: ${response.statusCode}');
      }

      currentPage++;
    } catch (error) {
      print('API 호출 에러: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About this place'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchDataFromBackend,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contentList.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  children: [
                    Text(
                      '${contentList[index]['nickName']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 20.0,
                      ),
                    ),
                    Icon(Icons.account_circle, color: Colors.blue), // 닉네임 옆 아이콘
                  ],
                ),
              ),
              SizedBox(height: 5), // 닉네임과 콘텐트 사이의 간격
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFF87CEFA),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${contentList[index]['content']}'),
                ),
              ),
              SizedBox(height: 30), // Add some spacing
            ],
          );
        },
      ),
    );
  }
}
