import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapdesign_flutter/community/blog_create_screen.dart';
import 'package:mapdesign_flutter/community/blog_detail_screen.dart';
import 'package:mapdesign_flutter/community/search_screen.dart';

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  List<BlogPost> blogPosts = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('장소이름'),
        ),
        body: ListView.builder(
          itemCount: blogPosts.length,
          itemBuilder: (context, index) {
            return Card(
              child: InkWell(
                onTap: () {
                  // Navigate to the BlogDetailScreen when a blog post is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlogDetailScreen(
                        title: blogPosts[index].title,
                        imageUrl: blogPosts[index].imageUrl!,
                        content: blogPosts[index].content,
                        comments: 1,
                        // Provide a value for comments
                        likes: 2,
                        // Provide a value for likes
                        author: '사용자 닉네임',
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    // Left side - Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      // 모서리를 둥글게 만듭니다
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          blogPosts[index].imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                                    blogPosts[index].title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    blogPosts[index].content,
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
                                Text('10'),
                                SizedBox(width: 10),
                                Icon(Icons.chat_bubble_outline),
                                SizedBox(width: 4),
                                Text('10'),
                              ],
                            ),
                            SizedBox(height: 8),
                            // 로딩 상태에 따라 CircularProgressIndicator를 표시
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
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
          ],
          onTap: (int index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlogCreateScreen(), // 글작성 페이지 이동
                ),
              ).then(
                (newPost) {
                  if (newPost != null) {
                    setState(
                      () {
                        blogPosts.add(newPost);
                      },
                    );
                  }
                },
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
          },
        ),
      ),
    );
  }
}
