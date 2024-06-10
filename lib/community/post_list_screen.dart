import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:mapdesign_flutter/community/post_create_screen.dart';
import 'package:mapdesign_flutter/community/search_screen.dart';
import 'package:mapdesign_flutter/community/socket_chat.dart';
import 'package:mapdesign_flutter/user_info.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/community/post_detailed_screen.dart';
import 'package:mapdesign_flutter/APIs/backend_server.dart';

String baseUrl = '${ServerConf.url}';

class Post {
  String boardTitle;
  String boardContent;
  Uint8List? image;
  int likeCount;
  int commentCount;
  int postId;

  Post(this.boardTitle, this.boardContent, this.image, this.likeCount, this.commentCount, this.postId);

  Post.fromJson(Map json)
      : boardTitle = json["boardTitle"],
        boardContent = json["boardContent"],
        image = (json["image"] != null) ? base64.decode(json["image"]) : null,
        likeCount = json["likeCount"],
        commentCount = json["commentCount"],
        postId = json["postId"];
}

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key, required this.locationId});
  final int locationId;

  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final StreamController<List<Post>> _streamController = StreamController<List<Post>>.broadcast();
  int currentPage = 0;
  bool isLoading = false;
  List<Post> dataList = [];
  late RefreshController _refreshController;  // late 키워드를 사용하여 나중에 초기화할 수 있도록 설정합니다.
  final ScrollController _scrollController = ScrollController();

  Future<void> _initData() async {
    await fetchData();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _initData();
    _scrollController.addListener(_scrollListener);
  }

  void _refresh() async {
    try {
      List<Post> newPost = await getPostList(widget.locationId, 0);
      if (newPost.isNotEmpty) {
        setState(() {
          dataList = newPost;
          currentPage = 1;
        });
        _streamController.add(dataList);
      }
    } catch (e) {
      print('Error: $e');
    }
    _refreshController.refreshCompleted();
  }

  void _loading() async {
    try {
      List<Post> newPost = await getPostList(widget.locationId, currentPage);
      if (newPost.isNotEmpty) {
        setState(() {
          dataList.addAll(newPost);
          currentPage++;
        });
        _streamController.add(dataList);
      }
    } catch (e) {
      print('Error: $e');
    }
    _refreshController.loadComplete();
  }

  Future<void> fetchData() async {
    try {
      if (!isLoading) {
        isLoading = true;
        List<Post> newTodos = await getPostList(widget.locationId, currentPage);
        if (newTodos.isNotEmpty) {
          setState(() {
            dataList.addAll(newTodos);
            currentPage++;
          });
          _streamController.add(dataList);
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<List<Post>> getPostList(int locationId, int page) async {
    String url = 'http://$baseUrl/comm/board/paging/$locationId?page=$page';
    http.Client client = http.Client();
    List<Post> list = [];
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final postList = json.decode(utf8.decode(response.bodyBytes))["content"];
        postList.forEach((todo) {
          try {
            list.add(Post.fromJson(todo));
          } catch (e) {
            print('Error adding todo: $e');
          }
        });
      } else {
        print("error: ${response.statusCode}");
        throw Exception("Failed to load todos");
      }
    } catch (e) {
      print("error");
      throw Exception("Error while fetching todos");
    } finally {
      client.close();
    }
    return list;
  }

  Widget _buildListTile(AsyncSnapshot snapshot, int index) {
    String imageFilePath = 'asset/img/default.png';
    int id = snapshot.data[index].postId;
    String title = snapshot.data[index].boardTitle;
    String content = snapshot.data[index].boardContent;
    Uint8List? image = snapshot.data[index].image;
    int likes = snapshot.data[index].likeCount;
    int comment = snapshot.data[index].commentCount;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailLoader(
                postId: id,
              ),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: image != null
                  ? Image.memory(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                imageFilePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      content,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.favorite_outline, color: Colors.red),
                        SizedBox(width: 4),
                        Text('$likes'),
                        SizedBox(width: 10),
                        Icon(Icons.chat_bubble_outline, color: Colors.blue),
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

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      currentPage++;
      fetchData();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _streamController.close();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '자유게시판',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
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
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
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
              enablePullUp: true,
              enablePullDown: true,
              controller: _refreshController,
              onRefresh: _refresh,
              onLoading: _loading,
              child: StreamBuilder(
                stream: _streamController.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Center(child: Text('게시글이 없습니다.'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      return _buildListTile(snapshot, index);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
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
                builder: (context) => PostCreationScreen(locationId: widget.locationId),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(locationId: widget.locationId),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  locationId: widget.locationId,
                  nickName: UserInfo.userNickname,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
