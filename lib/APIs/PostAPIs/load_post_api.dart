import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/community/post_create_screen.dart';
import 'package:mapdesign_flutter/community/search_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';


Future<PostDetail> fetchPostDetail(int postId) async {
  final response = await http.get(Uri.parse('http://$baseUrl/comm/board/findBoard/$postId'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    return PostDetail(
      boardDto: BoardDto.fromJson(data['boardDto']),
      entityList: (data['entityList'] as List).map((e) => Entity.fromJson(e)).toList(),
      commentCount: data['commentCount'],
    );
  } else {
    throw Exception('Failed to load post detail');
  }
}


class PostDetail {
  final BoardDto boardDto;
  final List<Entity> entityList;
  final int commentCount;

  PostDetail({required this.boardDto, required this.entityList, required this.commentCount});
}

class BoardDto {
  final int postId;
  final String userId;
  final String boardWriter;
  final String boardTitle;
  final String boardContent;
  final int locationId;
  final int boardHit;
  final String createTime;
  final String? updateTime;
  final int likeCount;
  final int reportCount;
  final String? image;
  final int commentCount;

  BoardDto({
    required this.postId,
    required this.userId,
    required this.boardWriter,
    required this.boardTitle,
    required this.boardContent,
    required this.locationId,
    required this.boardHit,
    required this.createTime,
    this.updateTime,
    required this.likeCount,
    required this.reportCount,
    required this.image,
    required this.commentCount,
  });

  factory BoardDto.fromJson(Map<String, dynamic> json) {
    return BoardDto(
      postId: json['postId'],
      userId: json['userId'],
      boardWriter: json['boardWriter'],
      boardTitle: json['boardTitle'],
      boardContent: json['boardContent'],
      locationId: json['locationId'],
      boardHit: json['boardHit'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
      likeCount: json['likeCount'],
      reportCount: json['reportCount'],
      image: json['image'],
      commentCount: json['commentCount'],
    );
  }
}

class Entity {
  final int id;
  final String commentWriter;
  final String commentContent;
  final String creatTime;
  final int report;
  final int likeCount;
  final String userId;

  Entity({
    required this.id,
    required this.commentWriter,
    required this.commentContent,
    required this.creatTime,
    required this.report,
    required this.likeCount,
    required this.userId,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'],
      commentWriter: json['commentWriter'],
      commentContent: json['commentContent'],
      creatTime: json['creatTime'],
      report: json['report'],
      likeCount: json['likeCount'],
      userId: json['userId'],
    );
  }
}