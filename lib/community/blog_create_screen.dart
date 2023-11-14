import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BlogPost {
  final String title;
  final String content;
  final String author;
  final DateTime postedDate;
  final String? imageUrl; // Nullable imageUrl to store the image URL

  BlogPost({
    required this.title,
    required this.content,
    required this.author,
    required this.postedDate,
    this.imageUrl
  });
}

class BlogCreateScreen extends StatefulWidget {
  @override
  _BlogCreateScreenState createState() => _BlogCreateScreenState();
}

class _BlogCreateScreenState extends State<BlogCreateScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  String? imageUrl; // Store the selected image URL

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        imageUrl = pickedFile.path; // Store the selected image path
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
      body: Padding(
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
              Image.network(
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
              onPressed: () {
                String title = titleController.text;
                String content = contentController.text;

                // Create a new BlogPost with the image URL
                BlogPost newPost = BlogPost(
                  title: title,
                  content: content,
                  author: 'Your Author',
                  postedDate: DateTime.now(),
                  imageUrl: imageUrl,
                );
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
