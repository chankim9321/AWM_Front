import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/community/blog_create_screen.dart';
import 'package:mapdesign_flutter/community/search_screen.dart';
import 'package:mapdesign_flutter/community/blog_detail_screen.dart';
import 'dart:convert';
import 'dart:io';
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

class Post{
  String boardTitle;
  String boardContent;
  //File? frontToBackImage;
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


class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {

  StreamController<List<Post>> streamController = StreamController(); // 데이터를 받아들이는 스트림.
  int currentPage=0;
  int locationId = 1;
  bool isLoading = false;
  List<Post> dataList = []; // Track the data separately

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(_scrollListener);
    // Fetch data when the state is initialized
    /*getTodo(locationId, currentPage).then((todos) {
      streamController.add(todos);
    });*/
  }
  Future<void> _refresh() async {
    // Implement the logic to refresh your data
    currentPage++; // Reset the page to 0 when refreshing
    //_refreshController.loadComplete();
    await fetchData();
    //setState(() {});
  }
  /*Future<void> fetchData() async {
    try {
      List<Post> todos = await getTodo(locationId, currentPage);
      streamController.add(todos);
    } catch (e) {
      print('Error: $e');
      // Handle error (show a message, retry, etc.)
    }
  }*/
  Future<void> fetchData() async {
    try {
      if (!isLoading) {
        isLoading = true;
        List<Post> todos = await getTodo(locationId, currentPage);
        dataList.addAll(todos); // Append new data to existing list
        streamController.add(dataList.toList()); // Add the updated list to the stream
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
    }
  }
  Future<List<Post>> getTodo(int locationId, int page) async {
    String original = 'https://f42b-27-124-178-180.ngrok-free.app';
    String sub = "/board/paging/${locationId}?page=$page"; // http request를 보낼 url
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

  Widget _buildListTile (AsyncSnapshot snapshot, int index) { // 리스트 뷰에 들어갈 타일(작은 리스트뷰)를 만든다.
    int id = snapshot.data[index].postId;
    String title = snapshot.data[index].boardTitle;
    String content = snapshot.data[index].boardContent;
    http.ByteStream image = snapshot.data[index].image;
    int likes = snapshot.data[index].likeCount;
    int comment = snapshot.data[index].commentCount;
    print('commentCount');
    print(snapshot.data[index].commentCount);

    return Card(
      child: InkWell(
        onTap: () {
          // Navigate to the BlogDetailScreen when a blog post is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(
                postId: id,
                title: title,
                //imageUrl: image!,
                content: content,
                comments: comment,
                likes: likes,
                author: '사용자 닉네임',
              ),
            ),
            /*MaterialPageRoute(
              builder: (context) => BlogDetailScreen(
                postId: id,
                /*title: title,
                //imageUrl: image!,
                content: content,
                comments: comment,
                likes: likes,
                author: '사용자 닉네임',*/
              ),
            ),*/
          );
        },

        child: Row(
          children: [
            // Left side - Image
            ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                // 모서리를 둥글게 만듭니다
                child: /*FutureBuilder<Uint8List>(
                future: snapshot.data[index].image.toBytes(),
                builder: (context, bytesSnapshot) {
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
              ),*/
                Text('$id')
            ),

            // Right side - Content
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
                            style:
                            TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "$content",
                            overflow: TextOverflow.ellipsis, // 글자 생략
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
                    // 로딩 상태에 따라 CircularProgressIndicator를 표시
                    //isLoading
                    //? Center(child: CircularProgressIndicator())
                    //: SizedBox.shrink(), // 로딩 상태가 아닐 때는 숨김
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
    streamController.close(); // Close the stream controller
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Reached the end of the list, trigger custom loading function
      _refresh();
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
        ),



        body: Column(
          children: <Widget>[
            Flexible(
              child: SmartRefresher(
                controller: _refreshController,
                onLoading: _refresh,
                child: StreamBuilder(
                  stream: streamController.stream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.length-3,
                        itemBuilder: (context, index) {
                          if (index == snapshot.data.length - 1) {
                            //currentPage++;
                            _refresh(); // Trigger refresh when reaching the end
                          }
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
                  builder: (context) => PostCreationScreen(), // 글작성 페이지 이동
                ),
              );
            }
            else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(), //검색 페이지 이동
                ),
              );
            }
            else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(), //검색 페이지 이동
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
