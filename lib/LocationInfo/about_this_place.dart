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
  String jwtToken = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6Iuq5gOywrO2YuCIsInByb3ZpZGVyIjoiQXBwVXNlciIsIm5pY2tOYW1lIjoi6rCA66CMIiwicmFua1Njb3JlIjowLCJpYXQiOjE3MDE2MDMzMjEsImV4cCI6MTcwMTY0NjUyMX0.1aCtdD5wb79azh2g-EKIdhjFLg7811gAKDMw1errkWU';

  @override
  void initState() {
    super.initState();
    _fetchDataFromBackend();
  }

  Future<void> _fetchDataFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('https://79fd-211-224-31-97.ngrok-free.app/log/paging/1?page=$currentPage'),//paging과 ?page사이에는 {locationid}가 들어가야함
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);

        final logs = data['content'] as List;

        for (var log in logs) {
          final id = log['id'];
          final nickName = log['nickName'];
          final content = log['content'];
          final likeCount = log['likeCount'];
          final badCount = log['badCount'];

          setState(() {
            contentList.add({'id': id, 'nickName': nickName, 'content': content, 'likeCount': likeCount, 'badCount': badCount});
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
        Uri.parse('https://79fd-211-224-31-97.ngrok-free.app/user/logBoard/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$jwtToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          contentList.removeWhere((element) => element['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
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

  Future<void> _likePost(int id) async {
    try {
      final response = await http.post(
        Uri.parse('https://79fd-211-224-31-97.ngrok-free.app/user/logBoard/likeCount/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$jwtToken',
        },
        body: json.encode({
          'isLike': true,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          contentList.firstWhere((element) => element['id'] == id)['likeCount']++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추천이 완료되었습니다.')),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 추천하셨습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추천 실패')),
        );
      }
    } catch (error) {
      print('추천 에러: $error');
    }
  }

  Future<void> _dislikePost(int id) async {
    try {
      final response = await http.post(
        Uri.parse('https://79fd-211-224-31-97.ngrok-free.app/user/logBoard/badCount/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$jwtToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          contentList.firstWhere((element) => element['id'] == id)['badCount']++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비추천이 완료되었습니다.')),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미 비추천하셨습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비추천 실패')),
        );
      }
    } catch (error) {
      print('비추천 에러: $error');
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
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up, color: Colors.green),
                          onPressed: () {
                            if (contentList[index]['id'] != null) {
                              _likePost(contentList[index]['id']);
                            } else {
                              print('id is null');
                            }
                          },
                        ),
                        Text('${contentList[index]['likeCount']}'),
                        IconButton(
                          icon: Icon(Icons.thumb_down, color: Colors.red),
                          onPressed: () {
                            if (contentList[index]['id'] != null) {
                              _dislikePost(contentList[index]['id']);
                            } else {
                              print('id is null');
                            }
                          },
                        ),
                        Text('${contentList[index]['badCount']}'),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (contentList[index]['id'] != null) {
                          _deletePost(contentList[index]['id']);
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