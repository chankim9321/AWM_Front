import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:untitled/comment.dart';
import 'dart:convert';

class BlogDetailScreen extends StatefulWidget {
  final String title;
  final File? imageUrl;
  final String content;
  final int likes;
  final int comments;
  final String author;

  BlogDetailScreen({
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.likes,
    required this.comments,
    required this.author,
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
                    setState(() {
                      selectedMenu = item;
                    });
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
                      child: Image.file(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                      ),
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
