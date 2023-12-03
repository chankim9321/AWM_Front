import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class about_this_place extends StatefulWidget {
  @override
  _about_this_placeState createState() => _about_this_placeState();
}

class _about_this_placeState extends State<about_this_place> {
  int currentPage = 0;
  List<Map<String, dynamic>> contentList = [];
  String jwtToken = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6InNldW5neWVvYnNpbkBnbWFpbC5jb20iLCJwcm92aWRlciI6Imdvb2dsZSIsIm5pY2tOYW1lIjoi7KCc65OcIiwicmFua1Njb3JlIjowLCJpYXQiOjE3MDE0OTkyNjgsImV4cCI6MTcwMTU0MjQ2OH0.CoD5PhKnYAmQ2dSb_P7rBGQzMKJwd1ivkYWfAahnXhM';

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
          final id = log['id']; // 'postId'를 'id'로 변경
          final nickName = log['nickName'];
          final content = log['content'];

          setState(() {
            contentList.add({'id': id, 'nickName': nickName, 'content': content}); // 'postId'를 'id'로 변경
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

  Future<void> _deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/user/logBoard/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$jwtToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          contentList.removeWhere((element) => element['id'] == id); // 'postId'를 'id'로 변경
        });
        ScaffoldMessenger.of(context).showSnackBar( // 삭제 성공 메시지 추가
          SnackBar(content: Text('삭제가 완료되었습니다.')),
        );
      } else {
        if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('작성자가 아닙니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: ${response.statusCode}')),
          );
        }
      }
    } catch (error) {
      print('삭제 에러: $error');
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${contentList[index]['nickName']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (contentList[index]['id'] != null) { // 'postId'를 'id'로 변경
                          _deletePost(contentList[index]['id']); // 'postId'를 'id'로 변경
                        } else {
                          print('id is null');
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
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
              SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
