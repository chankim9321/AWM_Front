import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'dart:math';

class AboutThisPlace extends StatefulWidget {
  const AboutThisPlace({super.key, required this.locationId});
  final int locationId;

  @override
  _AboutThisPlaceState createState() => _AboutThisPlaceState();
}

class _AboutThisPlaceState extends State<AboutThisPlace> {
  int currentPage = 0;
  bool isExist = false;
  late final String? token;
  List<Map<String, dynamic>> contentList = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromBackend();
    _setToken();
  }

  void _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }

  Future<void> _fetchDataFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('http://${ServerConf.url}/comm/log/paging/${widget.locationId}?page=$currentPage'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedBody);
        final logs = data['content'] as List;
        isExist = true;
        for (var log in logs) {
          final id = log['id'];
          final nickName = log['nickName'];
          final content = log['content'];
          final likeCount = log['likeCount'];
          final badCount = log['badCount'];
          setState(() {
            contentList.add({
              'id': id,
              'nickName': nickName,
              'content': content,
              'likeCount': likeCount,
              'badCount': badCount
            });
          });
        }
      } else if (response.statusCode == 204) {
        isExist = false;
        print("컨텐츠 없음");
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
        Uri.parse('http://${ServerConf.url}/comm/user/logBoard/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
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
        Uri.parse('http://${ServerConf.url}/comm/user/logBoard/likeCount/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
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
        Uri.parse('http://${ServerConf.url}/comm/user/logBoard/badCount/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token!,
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
        title: Text(
          'Decision Voting',
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
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (token!.isNotEmpty) {
                _fetchDataFromBackend();
              } else {
                CustomDialog.showCustomDialog(context, "정보 업데이트", "로그인이 필요합니다.");
              }
            },
          ),
        ],
      ),
      body: !isExist
          ? Center(child: Text("여러분이 알고있는 정보를 입력해주세요!"))
          : ListView.builder(
        itemCount: contentList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 32, right: 10, left: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: contentList[index]['likeCount'] < contentList[index]['badCount']
                    ? [Colors.purpleAccent, Colors.redAccent]
                    : [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: contentList[index]['likeCount'] < contentList[index]['badCount']
                      ? Colors.redAccent.withOpacity(0.4)
                      : Colors.blueAccent.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(4, 4),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
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
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up, color: Colors.white),
                            onPressed: () {
                              if (contentList[index]['id'] != null) {
                                _likePost(contentList[index]['id']);
                              } else {
                                print('id is null');
                              }
                            },
                          ),
                          Text(
                            '${contentList[index]['likeCount']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.thumb_down, color: Colors.white),
                            onPressed: () {
                              if (contentList[index]['id'] != null) {
                                _dislikePost(contentList[index]['id']);
                              } else {
                                print('id is null');
                              }
                            },
                          ),
                          Text(
                            '${contentList[index]['badCount']}',
                            style: TextStyle(color: Colors.white),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              if (contentList[index]['id'] != null) {
                                _deletePost(contentList[index]['id']);
                              } else {
                                print('id is nulll');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    contentList[index]['content'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PretendardLight',
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
