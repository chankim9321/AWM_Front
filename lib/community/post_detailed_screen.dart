import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/APIs/PostAPIs/post_remove_api.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'dart:convert';
import 'dart:async';
import 'package:mapdesign_flutter/community/comment.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/APIs/PostAPIs/load_post_api.dart';
import 'package:mapdesign_flutter/community/post_modify_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/user_info.dart';

String baseUrl = ServerConf.url;

enum SampleItem { itemOne, itemTwo }

class PostDetailLoader extends StatefulWidget {
  const PostDetailLoader({super.key, required this.postId});
  final int postId;

  @override
  _PostDetailLoaderState createState() => _PostDetailLoaderState();
}

class _PostDetailLoaderState extends State<PostDetailLoader> {
  late Future<PostDetail> futurePostDetail;

  @override
  void initState() {
    super.initState();
    futurePostDetail = fetchPostDetail(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostDetail>(
      future: futurePostDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return PostDetailPage(postDetail: snapshot.data!);
        }
      },
    );
  }
}

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.postDetail});
  final PostDetail postDetail;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  SampleItem? selectedMenu;
  late PostDetail postDetail;
  TextEditingController searchController = TextEditingController();
  List<CommentWidget> mainComments = [];
  String? token;

  @override
  void initState() {
    super.initState();
    postDetail = widget.postDetail;
    _setToken();
  }

  Future<void> _setToken() async {
    token = await SecureStorage().readSecureData('token');
  }

  void onCommentAdded(CommentWidget newComment) async {
    bool success = await sendCommentToBackend(newComment, postDetail.boardDto.postId, token!);
    if (success) {
      setState(() {
        mainComments.add(newComment);
      });
    } else {
      print('Failed to send comment to the backend');
    }
  }

  Future<bool> sendCommentToBackend(CommentWidget newComment, int postId, String token) async {
    if (token == null) {
      return false;
    }
    try {
      final response = await http.post(
          Uri.parse('http://$baseUrl/comm/user/comment/save/$postId'),
          body: jsonEncode({
            'commentWriter': newComment.author,
            'commentContent': newComment.content,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          });
      return response.statusCode == 200;
    } catch (error) {
      print('Error sending comment to the backend: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var background = AssetImage(UserInfo.defaultProfileImage);
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글', style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white),),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton<SampleItem>(
            initialValue: selectedMenu,
            onSelected: (SampleItem item) {
              if (item == SampleItem.itemOne) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostModifyScreen(postId: widget.postDetail.boardDto.postId)),
                );
              } else if (item == SampleItem.itemTwo) {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('글 삭제'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: const <Widget>[
                            Text('정말로 삭제 하시겠습니까?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('취소'),
                          onPressed: () async {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                        ),
                        TextButton(
                          child: Text('확인'),
                          onPressed: () async {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                            bool response = await removePost(widget.postDetail.boardDto.postId, token!);
                            if (response) {
                              CustomDialog.showCustomDialog(context, "글 삭제", "게시글이 성공적으로 삭제되었습니다!");
                              Navigator.pop(context);
                              setState(() {});
                            } else {
                              CustomDialog.showCustomDialog(context, "글 삭제", "게시글을 삭제하지 못했습니다.");
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              postDetail.boardDto.boardTitle,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Text(
              postDetail.boardDto.boardWriter,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16.0),
            if (postDetail.boardDto.image != null && postDetail.boardDto.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.memory(
                  base64Decode(postDetail.boardDto.image!),
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(),
            SizedBox(height: 16.0),
            Text(
              postDetail.boardDto.boardContent,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {},
                ),
                Text('${postDetail.boardDto.likeCount}'),
                IconButton(
                  icon: Icon(Icons.chat, color: Colors.blue),
                  onPressed: () {},
                ),
                Text('${postDetail.entityList.length}'),
              ],
            ),
            SizedBox(height: 16),
            Text('댓글 (${postDetail.entityList.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: postDetail.entityList.length,
              itemBuilder: (context, index) {
                Entity entity = postDetail.entityList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: background,
                    ),
                    title: Text(
                      entity.commentWriter,
                      style: TextStyle(color: Colors.grey),
                    ),
                    subtitle: Text(entity.commentContent),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: () {
                CommentWidget newComment = CommentWidget(
                  author: UserInfo.userNickname,
                  content: searchController.text,
                  onCommentAdded: onCommentAdded,
                );
                searchController.clear();
                setState(() {
                  onCommentAdded(newComment);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
