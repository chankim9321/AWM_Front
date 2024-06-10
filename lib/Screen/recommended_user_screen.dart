import 'package:flutter/material.dart';
import 'dart:convert'; // Base64 디코딩을 위해 필요
import 'dart:typed_data';
import 'package:mapdesign_flutter/APIs/RecommendUserAPIs/get_favorite_category.dart';
import 'package:mapdesign_flutter/APIs/RecommendUserAPIs/get_same_category_user.dart';

class RecommendUserScreen extends StatefulWidget {
  const RecommendUserScreen({super.key});

  @override
  _RecommendUserScreenState createState() => _RecommendUserScreenState();
}

class _RecommendUserScreenState extends State<RecommendUserScreen> {
  List<dynamic> userData = [];
  bool isLoading = true;

  Future<void> _initData() async {
    final data = await GetSameCategoryUser.getSameCategoryUser();
    setState(() {
      isLoading = false;
      if (data != null) {
        userData = data;
      } else {
        userData = [];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('추천된 유저', style: TextStyle(fontSize: 20, fontFamily: 'PretendardLight')),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData.isEmpty
          ? Center(
        child: Text(
          '추천된 유저가 존재하지 않습니다',
          style: TextStyle(fontSize: 16, fontFamily: 'PretendardLight'),
        ),
      )
          : ListView.builder(
        itemCount: userData.length,
        itemBuilder: (context, index) {
          var user = userData[index];
          Uint8List imageBytes = base64Decode(user['image']);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: MemoryImage(imageBytes),
            ),
            title: Text(
              user['nickName'],
              style: TextStyle(fontFamily: 'PretendardLight'),
            ),
          );
        },
      ),
    );
  }
}
