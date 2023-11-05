import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // For File class
import 'package:image_picker/image_picker.dart'; // For XFile and ImagePicker




class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}
class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  XFile? _image; // 사용자 선택한 이미지

  // 특정 URL 이미지 경로
  final String imageUrl = 'https://static.wikia.nocookie.net/pokemon/images/a/aa/%EC%82%90_%EA%B3%B5%EC%8B%9D_%EC%9D%BC%EB%9F%AC%EC%8A%A4%ED%8A%B8.png/revision/latest/scale-to-width-down/200?cb=20170406071411&path-prefix=ko';

  @override
  Widget build(BuildContext context) {
    //final postService = Provider.of<PostService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('글 쓰기'),
            TextButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
              onPressed: () {
                final title = titleController.text;
                final content = contentController.text;
                final imageFile = _image != null ? File(_image!.path) : File(imageUrl);
                final post = Post(
                  title: title,
                  content: content,
                  image: imageFile,
                );

                //postService.addPost(post);

                titleController.clear();
                contentController.clear();
                setState(() {
                  _image = null;
                });
                Navigator.of(context).pop();
              },
              child: Text('게시'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),

              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: '내용',
                    enabledBorder: InputBorder.none),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              SizedBox(width: 100,child: TextField(),),
              GestureDetector(
                onTap: () async {
                  final imagePicker = ImagePicker();
                  final pickedImage = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );

                  setState(() {
                    _image = pickedImage;
                  });
                },
                child: _image != null
                    ? Image.file(File(_image!.path))
                    : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey,
                  child: Icon(Icons.camera_alt, size: 50),
                ),
              ),
              SizedBox(width: 10,child: TextField(),),
              SizedBox(
                width: 300,
                height: 60,
                child: FilledButton(
                  onPressed: () {
                    final title = titleController.text;
                    final content = contentController.text;
                    final imageFile = _image != null ? File(_image!.path) : File(imageUrl);
                    final post = Post(
                      title: title,
                      content: content,
                      image: imageFile,
                    );

                    //postService.addPost(post);

                    titleController.clear();
                    contentController.clear();
                    setState(() {
                      _image = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '게시하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class Post {
  final String title;
  final String content;
  final List<Comment> comments;
  final File? image; // 이미지 파일 추가

  Post({required this.title, required this.content, List<Comment>? comments,this.image})
      : comments = comments ?? [];
}

class Comment {
  final String text;
  final String author;
  Comment({required this.text, required this.author});
}

class CommentService with ChangeNotifier {
  final List<Comment> comments = [];

  void addComment(Comment comment) {
    comments.add(comment);
    notifyListeners();
  }
}

class PostService with ChangeNotifier {
  final List<Post> posts = [];

  void addPost(Post post) {
    posts.add(post);
    notifyListeners();
  }

  void addCommentToPost(int postIndex, Comment comment) {
    posts[postIndex].comments.add(comment);
    notifyListeners();
  }
}
