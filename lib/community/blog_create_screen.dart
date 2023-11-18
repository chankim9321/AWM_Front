import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class BlogPost {
  final String title;
  final String content;
  final String author;
  final int comments;
  final int likes;
  final File? imageUrl; // Nullable imageUrl to store the image URL
  final int postID;

  BlogPost({
    required this.title,
    required this.content,
    required this.author,
    required this.comments,
    required this.likes,
    required this.postID,
    required this.imageUrl

  });
  // Add a constructor for JSON serialization
  BlogPost.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'],
        author = json['author'],
        comments = json['comments'],
        likes = json['likes'],
        postID = json['postID'],
        imageUrl = json['imageUrl'] != null ? File(json['imageUrl']) : null;

  // Add a method to convert the object to JSON
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'author': author,
    'comments': comments,
    'likes': likes,
    'postID': postID,
    'imageUrl': imageUrl?.path, // Convert File to path string
  };
}

class BlogCreateScreen extends StatefulWidget {
  @override
  _BlogCreateScreenState createState() => _BlogCreateScreenState();
}

class _BlogCreateScreenState extends State<BlogCreateScreen> {

  Future<void> sendNewPostToBackendWithLocation(
      double latitude, double longitude, BlogPost newPost) async {
    final response = await http.post(
      Uri.parse('YOUR_BACKEND_URL/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
        ...newPost.toJson(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create a new blog post');
    }
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  File? imageUrl; // Store the selected image URL

  Future pickImage() async {
    final pickedFile =
    await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageUrl = File(pickedFile.path); // Store the selected image path
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 글 등록'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                //labelText: '제목',
                hintText: '제목을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 10),
            if (imageUrl != null)
              Image.file(
                imageUrl!,
                width: 200,
                height: 200,
              ),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('이미지 선택'),
              style: ElevatedButton.styleFrom(
                primary: Colors.transparent, // 버튼 색을 투명하게 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async{
                String title = titleController.text;
                String content = contentController.text;

                // Create a new BlogPost with the image URL
                BlogPost newPost = BlogPost(
                  title: title,
                  content: content,
                  author: 'Author',
                  imageUrl: imageUrl,
                  likes: 1,
                  comments: 1,
                  postID: 1,
                );
                double userLatitude = 37.7749;
                double userLongitude = -122.4194;
                await sendNewPostToBackendWithLocation(userLatitude, userLongitude, newPost);

                Navigator.pop(context, newPost);
              },
              child: Text('등록하기'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
