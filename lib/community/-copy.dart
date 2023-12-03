import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/community/blog_create_screen.dart';
import 'package:mapdesign_flutter/community/search_screen.dart';
import 'package:mapdesign_flutter/community/blog_detail_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:mapdesign_flutter/community/chat.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:typed_data';
import 'package:mapdesign_flutter/community/comment.dart';
/*class Post{
  String boardTitle;
  String boardContent;
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
            : http.ByteStream(Stream.empty()),
        likeCount = json["likeCount"],
        commentCount = json["commentCount"],
        postId = json["postId"];
}

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  StreamController _streamController = StreamController.broadcast();
  int currentPage = 0;
  int postId = 34;
  int locationId = 1;
  bool isLoading = false;
  List<Post> dataList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(_scrollListener); // 스크롤 리스너 추가
  }

  Future<void> _refresh() async {
    currentPage++;
    await fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (!isLoading) {
        isLoading = true;
        List<Post> newTodos = await getTodo(postId);
        dataList.addAll(newTodos);
        _streamController.add(newTodos);
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<List<Post>> getTodo(int postId) async {
    String original = 'https://f42b-27-124-178-180.ngrok-free.app';
    String sub = "/board/findBoard/${postId}";
    String url = original + sub;
    http.Client _client = http.Client();
    List<Post> list = [];
    try {
      final response = await _client.get(Uri.parse(url));
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("이전");
        final todos = json.decode(utf8.decode(response.bodyBytes))["boardDto"];
        print("이후");
        //final comm = json.decode(utf8.decode(response.bodyBytes))["entityList"];
        todos.forEach((todo) {
          try {
            print("여기부터");
            list.add(Post.fromJson(todo));
            print("아닌가?");
          } catch (e) {
            print('Error adding todo: $e');
          }
          print("여기도?");
        });
      } else {
        throw Exception("Failed to load todos");
      }
    } catch (e) {
      throw Exception("Error while fetching todos");
    } finally {
      _client.close();
    }
    return list;
  }

  Widget _buildListTile (AsyncSnapshot snapshot, int index) {
    print('durl');
    int id = snapshot.data[index].postId;
    String title = snapshot.data[index].boardTitle;
    String content = snapshot.data[index].boardContent;
    http.ByteStream image = snapshot.data[index].image;
    int likes = snapshot.data[index].likeCount;
    int comment = snapshot.data[index].commentCount;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(
                postId: id,
                title: title,
                imageUrl: image,
                content: content,
                comments: comment,
                likes: likes,
                author: '사용자 닉네임',
              ),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: FutureBuilder<Uint8List>(
                future: snapshot.data[index].image.toBytes(),
                builder: (context, bytesSnapshot) {
                  if (bytesSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (bytesSnapshot.hasError) {
                    return Text('Error loading image');
                  } else if (!bytesSnapshot.hasData) {
                    print('여기');
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$title",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "$content",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.favorite_outline),
                        SizedBox(width: 4),
                        Text('$likes'),
                        SizedBox(width: 10),
                        Icon(Icons.chat_bubble_outline),
                        SizedBox(width: 4),
                        Text('$comment'),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      currentPage++;  // 페이지 증가
      fetchData();    // 데이터 재요청
    }
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('장소이름'),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  currentPage = 0;
                  dataList = [];
                  fetchData();
                });
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                controller: _refreshController,
                child: StreamBuilder(
                  stream: _streamController.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return _buildListTile(snapshot, index);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: '글쓰기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: '채팅',
            ),
          ],
          onTap: (int index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostCreationScreen(),
                ),
              );
            }
            else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            }
            else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Detail Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostDetailLoader(),
    );
  }
}
enum SampleItem { itemOne, itemTwo}
class PostDetailLoader extends StatefulWidget {
  @override
  _PostDetailLoaderState createState() => _PostDetailLoaderState();
}

class _PostDetailLoaderState extends State<PostDetailLoader> {
  late Future<PostDetail> futurePostDetail;

  @override
  void initState() {
    super.initState();
    futurePostDetail = fetchPostDetail();
  }

  Future<PostDetail> fetchPostDetail() async {
    final response = await http.get(Uri.parse('https://f42b-27-124-178-180.ngrok-free.app/board/findBoard/32'));

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostDetail>(
      future: futurePostDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return PostDetailPage(postDetail: snapshot.data!);
        }
      },
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final PostDetail postDetail;
  SampleItem? selectedMenu;
  TextEditingController searchController = TextEditingController();
  PostDetailPage({required this.postDetail});


  List<CommentWidget> mainComments = [];

  void onCommentAdded(CommentWidget newComment) async {
    // Assuming you have a method in your backend API to handle comment creation
    bool success = await sendCommentToBackend(newComment);

    /*if (success) {
      setState(() {
        chatCount++;
        mainComments.add(newComment);
      });
    } else {
      // Handle the case where sending the comment to the backend fails
      // You may want to show an error message to the user
      print('Failed to send comment to the backend');
    }*/
  }
  Future<bool> sendCommentToBackend(CommentWidget newComment) async {
    // Replace 'YOUR_BACKEND_API_URL' with the actual URL of your backend API
    try {
      final response = await http.post(
        Uri.parse('f42b-27-124-178-180.ngrok-free.app/comments'), // Replace with the actual URL
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
                    if (item == SampleItem.itemOne) {
                      // 수정 선택 시의 로직 추가
                      // 수정 화면으로 이동하거나 수정하는 기능을 구현하세요.
                    } else if (item == SampleItem.itemTwo) {
                      // 삭제 선택 시의 로직 추가
                      //_showDeleteConfirmationDialog(widget.postId);
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
              /*Text(
                'Title: ${postDetail.boardDto.boardTitle}',
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Text('Writer: ${postDetail.boardDto.boardWriter}'),
              Text(
                'Content: ${postDetail.boardDto.boardContent}',
                style: TextStyle(fontSize: 16.0),
              ),*/
              SizedBox(height: 16),
              // Display the image
              postDetail.boardDto.image.isNotEmpty
                  ? Image.memory(base64Decode(postDetail.boardDto.image))
                  : Container(), // Check if the image data is not empty
              SizedBox(height: 16.0),
              /*Row(
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
                  Text('${postDetail.boardDto.commentCount}'),
                ],
              ),*/
              //SizedBox(height: 16),
              Text('Comments (${postDetail.commentCount})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: postDetail.entityList.length,
                itemBuilder: (context, index) {
                  Entity entity = postDetail.entityList[index];
                  return ListTile(
                    title: Text(entity.commentWriter),
                    subtitle: Text(entity.commentContent),
                  );
                },
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
        ),
      ),
    );
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
  final String image;
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