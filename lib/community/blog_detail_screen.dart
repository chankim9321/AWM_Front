import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/community/comment.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
String authToken =
    'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VybmFtZSI6InFxd3dhczEyMzRAZ21haWwuY29tIiwicHJvdmlkZXIiOiJnb29nbGUiLCJuaWNrTmFtZSI6Iuy5tO2DgOumrOuCmCIsInJhbmtTY29yZSI6MCwiaWF0IjoxNzAxNDk4NTczLCJleHAiOjE3MDE1NDE3NzN9.TLs6wTWIA1dIdzHCt7k-6aMgIv2wHmAv5IXkc1lJzvA'; // Replace with your actual authentication token

class BlogDetailScreen extends StatefulWidget {
  final String title;
  final http.ByteStream? imageUrl;
  final String content;
  final int likes;
  final int comments;
  final String author;
  final int postId;

  BlogDetailScreen({
    required this.title,
    required this.imageUrl,
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

class Post{
  String boardTitle;
  String boardContent;
  File? frontToBackImage;
  http.ByteStream? image;
  int likeCount;
  int commentCount;
  int postId;

  Post(this.boardTitle, this.boardContent, this.image, this.likeCount, this.commentCount, this.postId);

  Post.fromJson(Map json)
      : boardTitle = json["boardTitle"],
        boardContent = json["boardContent"],
        image = (json["image"] != null)
            ? http.ByteStream.fromBytes(base64.decode(json["image"]))
            : http.ByteStream(Stream.empty()), // Provide an empty ByteStream if image is null
        likeCount = json["likeCount"],
        commentCount = json["commentCount"],
        postId = json["postId"];

}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  SampleItem? selectedMenu;
  int likeCount = 0; // 초기 좋아요 수
  bool isLiked = false;
  int bookmarkCount = 0; // 초기 북마크 수
  bool isbookmark = false;
  bool isnotice = false;
  int chatCount = 0; // 초기 댓글 수


  Future<List<Post>> getTodo(int postid) async {
    String original = 'https://f42b-27-124-178-180.ngrok-free.app';
    String sub = "/board/findBoard/${postid}"; // http request를 보낼 url
    //String url = "https://ae63-203-230-231-145.ngrok-free.app//board/paging/${locationId}?page=$page"; // http request를 보낼 url
    //String url = "http://192.168.43.20:8080/board/paging/${locationId}?page=$page"; // http request를 보낼 url
    //String url = "https://jsonplaceholder.typicode.com/todos"; // http request를 보낼 url
    String url = original + sub;
    print(url);
    http.Client _client = http.Client(); // http 클라이언트 사용
    List<Post> list = [];
    try {
      print("durl?");
      final response = await _client.get(Uri.parse(url));
      print('상태 =');
      print(response.statusCode);

      if (response.statusCode == 200) {

        //final todos = json.decode(utf8.decode(response.bodyBytes));
        final todos = json.decode(utf8.decode(response.bodyBytes))["content"];
        print('s'*70);
        print(todos);
        print('Todos: $todos');
        print('a'*70);
        todos.forEach((todo) {
          print('123'*35);
          print('Processing todo: $todo');
          print("여기error");
          try {
            list.add(Post.fromJson(todo));
          } catch (e) {
            print('Error adding todo: $e');
          }
          list.add(Post.fromJson(todo)); // Remove this line
          print("error 지남");
        });
        print('여기!');
        todos.forEach((todo) => list.add(Post.fromJson(todo)));
        print('아닌가?');
        print('s'*70);
        print(todos);


      } else {
        // Handle the case where the server responded with an error.
        print("Failed to load todos. Status code: ${response.statusCode}");
        // You can throw an exception, show an error message, or handle it in any way you prefer.
        throw Exception("Failed to load todos");
      }
    } catch (e) {
      // Handle other potential errors such as network issues.
      // You can throw an exception, show an error message, or handle it in any way you prefer.
      print('catch 문');
      throw Exception("Error while fetching todos");
    } finally {
      _client.close(); // Close the client to free up resources.
    }
    return list;
  }


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
    bool success = await sendCommentToBackend(newComment, widget.postId);

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

  Future<bool> sendCommentToBackend(CommentWidget newComment, int postid) async {
    // Replace 'YOUR_BACKEND_API_URL' with the actual URL of your backend API
    try {
      final response = await http.post(
        Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/user/comment/save/${postid}'), // Replace with the actual URL
          body: jsonEncode({
            'commentWriter': newComment.author,
            'commentContent': newComment.content,
          }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : '$authToken',
        }
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        // 글 삭제 성공
        print('댓글 성공');
        Navigator.pop(context);
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
  Future<Uint8List> getImageBytes() async {
    Completer<Uint8List> completer = Completer();
    http.ByteStream imageStream = widget.imageUrl!;
    print('imageStream');
    print(imageStream);
    List<int> imageBytes = [];
    await imageStream.listen((List<int> chunk) {
      imageBytes.addAll(chunk);
    }, onDone: () {
      completer.complete(Uint8List.fromList(imageBytes));
    }, onError: (error) {
      completer.completeError(error);
    });
    print('completer');
    print(completer);
    print('completer.future');
    print(completer.future);
    return completer.future;
  }
  // 글 삭제 함수

  Future<void> _deletePost(postId) async {

    try {
      final response = await http.delete(
        Uri.parse("https://f42b-27-124-178-180.ngrok-free.app/user/remove/${postId}"),
        headers: {'Content-Type': 'application/json',
          'Authorization' : '$authToken'},
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
                      child: Container(
                        child: FutureBuilder<Uint8List>(
                          future: getImageBytes(),
                          builder: (context, bytesSnapshot) {
                            print('Received ${bytesSnapshot.data?.length} bytes');
                            if (bytesSnapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (bytesSnapshot.hasError) {
                              return Text('Error loading image');
                            } else if (!bytesSnapshot.hasData) {
                              return Text('No image data');
                            } else {
                              return Image.memory(
                                bytesSnapshot.data!,
                                width: 100,
                                height: 100,
                              );
                            }
                          },
                        ),
                      ),
                      //Text('456'),
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
