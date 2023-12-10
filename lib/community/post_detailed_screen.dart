import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/APIs/PostAPIs/post_remove_api.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:mapdesign_flutter/community/comment.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/APIs/PostAPIs/load_post_api.dart';
import 'package:mapdesign_flutter/community/post_modify_screen.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:mapdesign_flutter/user_info.dart';

String baseUrl = ServerConf.url;

enum SampleItem { itemOne, itemTwo}

class PostDetailLoader extends StatefulWidget {
  const PostDetailLoader({super.key, required this.postId,});
  final int postId;
  //final PostDetail postDetail;
  //final int postName;
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
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text('Error: ${snapshot.error}');
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
    // TODO: implement initState
    super.initState();
    postDetail = widget.postDetail;
    _setToken();
  }
  Future<void> _setToken() async{
    token = await SecureStorage().readSecureData('token');
  }
  void onCommentAdded(CommentWidget newComment) async {
    bool success = await sendCommentToBackend(newComment ,postDetail.boardDto.postId, token!);
    if (success) {
      setState(() {
        mainComments.add(newComment);
      });
    } else {
      print('Failed to send comment to the backend');
    }
  }
  Future<bool> sendCommentToBackend(CommentWidget newComment, int postId, String token) async {
    // Replace 'YOUR_BACKEND_API_URL' with the actual URL of your backend API
    if(token == null){
      return false;
    }
    try {
      final response = await http.post(
          Uri.parse('http://$baseUrl/user/comment/save/$postId'), // Replace with the actual URL
          body: jsonEncode({
            'commentWriter': newComment.author,
            'commentContent': newComment.content,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Authorization' : token,
          }
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // 글 삭제 성공
        print('댓글 성공');
        //Navigator.pop(context);
      } else {
        // 글 삭제 실패
        print('댓글 실패 - ${response.statusCode}');
        // 실패에 대한 추가 처리를 수행할 수 있습니다.
      }
      return response.statusCode == 200;
    } catch (error) {
      print('Error sending comment to the backend: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var background;
    if(UserInfo.profileImage.isEmpty){
      background = AssetImage(UserInfo.defaultProfileImage);
    }
    else{
      background = Image.memory(UserInfo.profileImage);
    }
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostModifyScreen(postId: widget.postDetail.boardDto.postId))
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
                                children: const<Widget>[
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
                                  bool response = await removePost(
                                      widget.postDetail.boardDto.postId, token!);
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
                        }
                      );
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
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                postDetail.boardDto.boardTitle,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Text(postDetail.boardDto.boardWriter),
              SizedBox(height: 16.0),
              if (postDetail.boardDto.image != null && postDetail.boardDto.image!.isNotEmpty)
                Image.memory(
                  base64Decode(postDetail.boardDto.image!),
                  fit: BoxFit.cover,
                )
              else
                Container(),
              SizedBox(height: 16.0),
              Text(
                postDetail.boardDto.boardContent,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16),
              // Display the image
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                        Icons.favorite
                      /*isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.black,
                    */),
                    //onPressed: toggleLike,
                    onPressed: (){},
                  ),
                  Text('${postDetail.boardDto.likeCount}'),
                  IconButton(
                    icon: Icon(
                        Icons.chat
                      /*isbookmark ? Icons.chat : Icons.chat_bubble_outline,
                      color: isbookmark ? Colors.blue : Colors.black,
                    */),
                    //onPressed: togglebookmark,
                    onPressed: (){},
                  ),
                  Text('${postDetail.entityList.length}'),
                ],
              ),
              SizedBox(height: 16),
              Text('Comments (${postDetail.entityList.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: postDetail.entityList.length,
                itemBuilder: (context, index) {
                  Entity entity = postDetail.entityList[index];
                  // 댓글 위젯
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: background,
                    ),
                    title: Text(
                      entity.commentWriter,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    subtitle: Text(entity.commentContent),
                  );
                },
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
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
                  author: UserInfo.userNickname,
                  // Replace with the actual username or author
                  content: searchController.text,
                  onCommentAdded: onCommentAdded, // Pass the callback
                );
                // Notify the parent widget about the new comment
                onCommentAdded(newComment);
                // Clear the input field
                searchController.clear();
                setState(() {

                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
