import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/community/comment.dart';
import 'dart:convert';

class BlogDetailScreen extends StatefulWidget {
  final String title;
  //final File? imageUrl;
  final String content;
  final int likes;
  final int comments;
  final String author;
  final int postId;

  BlogDetailScreen({
    required this.title,
    //required this.imageUrl,
    required this.content,
    required this.likes,
    required this.comments,
    required this.author,
    required this.postId,
  });

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

enum SampleItem { itemOne, itemTwo}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  SampleItem? selectedMenu;
  int likeCount = 0; // 초기 좋아요 수
  bool isLiked = false;
  int bookmarkCount = 0; // 초기 북마크 수
  bool isbookmark = false;
  bool isnotice = false;
  int chatCount = 0; // 초기 댓글 수

  void toggleLike() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
      }
      isLiked = !isLiked;
    });
  }

  void togglebookmark() {
    setState(() {
      if (isbookmark) {
        bookmarkCount--;
      } else {
        bookmarkCount++;
      }
      isbookmark = !isbookmark;
    });
  }

  void togglenotice() {
    setState(() {
      isnotice = !isnotice;
    });
  }

  TextEditingController searchController = TextEditingController();

  bool isExpanded = false;
  int maxLines = 1;
  List<CommentWidget> mainComments = [];

  void onCommentAdded(CommentWidget newComment) async {
    // Assuming you have a method in your backend API to handle comment creation
    bool success = await sendCommentToBackend(newComment);

    if (success) {
      setState(() {
        chatCount++;
        mainComments.add(newComment);
      });
    } else {
      // Handle the case where sending the comment to the backend fails
      // You may want to show an error message to the user
      print('Failed to send comment to the backend');
    }
  }

  Future<bool> sendCommentToBackend(CommentWidget newComment) async {
    // Replace 'YOUR_BACKEND_API_URL' with the actual URL of your backend API
    try {
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_API_URL/comments'), // Replace with the actual URL
        body: {
          'author': newComment.author,
          'content': newComment.content,
        },
      );

      return response.statusCode == 200;
    } catch (error) {
      print('Error sending comment to the backend: $error');
      return false;
    }
  }
  // 글 삭제 함수
  Future<void> _deletePost(postId) async {
    try {
      final response = await http.delete(
        Uri.parse("https:// 주소 /$postId"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 글 삭제 성공
        print('글 삭제 성공');
        Navigator.pop(context);
      } else {
        // 글 삭제 실패
        print('글 삭제 실패 - ${response.statusCode}');
        // 실패에 대한 추가 처리를 수행할 수 있습니다.
      }
    } catch (e) {
      // 예외 처리
      print('에러 발생: $e');
    }
  }

  void _showDeleteConfirmationDialog(int postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("삭제 확인"),
          content: Text("정말로 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                // 실제 삭제 로직 수행
                _deletePost(postId);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("삭제"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                PopupMenuButton<SampleItem>(
                  initialValue: selectedMenu,
                  // Callback that sets the selected popup menu item.
                  onSelected: (SampleItem item) {
                    if (item == SampleItem.itemOne) {
                      // 수정 선택 시의 로직 추가
                      // 수정 화면으로 이동하거나 수정하는 기능을 구현하세요.
                    } else if (item == SampleItem.itemTwo) {
                      // 삭제 선택 시의 로직 추가
                      _showDeleteConfirmationDialog(widget.postId);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('수정'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('삭제'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.author),
                  SizedBox(height: 10.0),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    widget.content,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 10.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      child: /*Image.file(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                      ),*/
                      Text('456'),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                        onPressed: toggleLike,
                      ),
                      Text('$likeCount'),
                      IconButton(
                        icon: Icon(
                          isbookmark ? Icons.bookmark : Icons.bookmark_border,
                          color: isbookmark ? Colors.blue : Colors.black,
                        ),
                        onPressed: togglebookmark,
                      ),
                      Text('$bookmarkCount'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('댓글'),
                      Text(' $chatCount'),
                    ],
                  ),
                  if (mainComments.isNotEmpty)
                    ...mainComments,
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Create a new comment
                    CommentWidget newComment = CommentWidget(
                      author: 'Your Username',
                      // Replace with the actual username or author
                      content: searchController.text,
                      onCommentAdded: onCommentAdded, // Pass the callback
                    );

                    // Notify the parent widget about the new comment
                    onCommentAdded(newComment);

                    // Clear the input field
                    searchController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
