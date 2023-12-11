import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:mapdesign_flutter/community/post_create_screen.dart';
import 'package:mapdesign_flutter/community/search_screen.dart';
import 'package:mapdesign_flutter/community/socket_chat.dart';
import 'package:mapdesign_flutter/user_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:typed_data';
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

  Future<void> _initData() async{
    await fetchData();
  }
  @override
  void initState() {
    super.initState();
    _initData();
    _refreshController = RefreshController(initialRefresh: false);
    _scrollController.addListener(_scrollListener);
  }
  // 위로 스크롤 했을 때, 최신글이 불러오게끔 설정
  void _refresh() async {
    try {
      List<Post> newPost = await getPostList(widget.locationId, currentPage);
      print('currentPage');
      print(currentPage);
      if (newPost.isNotEmpty) {
        dataList.insertAll(0, newPost);
        _streamController.add(dataList);
      }
    } catch (e) {
      print('Error: $e');
    }
    _refreshController.refreshCompleted();
  }
  // 아래로 스크롤 했을 때, 과거글이 불러오게끔 설정
  void _loading() async {
    try {
      currentPage++;
      List<Post> newPost = await getPostList(widget.locationId, currentPage);
      print('currentPage');
      print(currentPage);
      if (newPost.isNotEmpty) {
        dataList.insertAll(dataList.length, newPost);
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
          dataList.addAll(newTodos);
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
    String original = 'http://$baseUrl';
    String sub = "/board/paging/$locationId?page=$page";
    String url = original + sub;
    http.Client client = http.Client();
    print(url);
    List<Post> list = [];
    try {
      print(url);
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final postList = json.decode(utf8.decode(response.bodyBytes))["content"];
        print(postList.length);
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
      child: InkWell(
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
              borderRadius: BorderRadius.circular(20.0),
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
                fit: BoxFit.cover, // Adjust the fit based on your requirement
              )
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
                            title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            content,
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

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      currentPage++;
      fetchData();
    }
  }
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('자유게시판',
            style: TextStyle(
              color: AppColors.instance.white,
            ),
          ),
          backgroundColor: AppColors.instance.skyBlue,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh,
                color: AppColors.instance.white,
              ),
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
                onRefresh: _refresh, // 위로 스크롤
                onLoading: _loading, // 아래로 스크롤
                child: StreamBuilder(
                  stream: _streamController.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
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
            }
            else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(locationId: widget.locationId),
                ),
              );
            }
            else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(locationId: widget.locationId, nickName: UserInfo.userNickname,),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}