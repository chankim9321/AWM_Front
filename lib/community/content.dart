import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}
enum SampleItem { itemOne, itemTwo, itemThree }

class _PostDetailScreenState extends State<PostDetailScreen> {
  SampleItem? selectedMenu;
  int likeCount = 10; // 초기 좋아요 수
  bool isLiked = false;
  int chatCount = 10; // 초기 댓글 수
  bool ischat = false;
  bool isnotice = false; // 초기 알림 설정


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
  void togglechat() {
    setState(() {
      if (ischat) {
        chatCount--;
      } else {
        chatCount++;
      }
      ischat = !ischat;
    });
  }
  void togglenotice() {
    setState(() {
      isnotice = !isnotice;
    });
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '게시물 제목',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    isnotice ? Icons.notifications : Icons.notifications_off,
                    color: isnotice ? Colors.red : Colors.white,
                  ),
                  onPressed: togglenotice,
                ),

                PopupMenuButton<SampleItem>(
                  initialValue: selectedMenu,
                  // Callback that sets the selected popup menu item.
                  onSelected: (SampleItem item) {
                    setState(() {
                      selectedMenu = item;
                    });
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemOne,
                      child: Text('신고'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.itemTwo,
                      child: Text('유저차단'),
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
          Expanded(child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('사용자 닉네임'),
                SizedBox(height: 10.0),
                Text(
                  //'게시물 내용 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus eget lectus eget turpis efficitur suscipit. Vestibulum quis velit eu velit bibendum tempus. Sed dignissim felis et suscipit.',
                  '게시물내용',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10.0),

                Image.network(
                  //'https://static.wikia.nocookie.net/pokemon/images/a/aa/%EC%82%90_%EA%B3%B5%EC%8B%9D_%EC%9D%BC%EB%9F%AC%EC%8A%A4%ED%8A%B8.png/revision/latest/scale-to-width-down/200?cb=20170406071411&path-prefix=ko',
                  'https://lh3.googleusercontent.com/fife/AK0iWDzQiPOTWGjc3CJEo_D762eA1DXRWUDxdhtonJwZriX6OQqS_p3rfLMG-h3Z7nuMWiJuvxs9S-WHvL1OnIbCwpWBmI-A3UtaXaXlPJzPqFbgJY6Sp2IN--EtOv_wRlYadwmtWwAIrjDJB_Jx1IKew5B71yTjBL4zgN0GK9-We_GaUWkFRGl9NxFkMDNrmkah3f4DSF7-QlT6gDKn1ynNpUGkfmVJ8wPz0R1SxArTpZlkhaMkd7i9CBcOmAX445TJ6s4b5umF2p-apvhWgJdVDAm1cR6bPKLnforY03YOfm0fqoqAb73YNIJpTdxqlmjQc7UMca0rRkV3R_JgIG6RZg7169q_lFJvhki9idnRm0JNDkgTyENI3cV5zYLtHN5X1gw2txek-6FYCwijTPnuWIo_x-HBtiR2I1npJjSiR0st3GgvhaeaUt4-xJCKywQqf4iFJA9I94IVt9oqYZraFUna1JXLqUpA3vCXCBSeALmQ7sQrses3I8CSMOeY_nKG2RSAxcu5jAib6jmvlb84QS9k_0F2Wti7kOKuABmTEfsFUnTpyc4KpdNktzEY7wwTYLigQmb0fh7Lrg9GAOWV4wz3eLlVPqjcLxCWDte5O2tBN9CAPL3dM3gazpgcvf3AwQq7o_2-xrrCzaACr-7GqItL8Tc0qCn35BXDdEqOhyjfa6cp2IRpZB3g03Gb_rzf_XqdWX5XEJWRY3b-0XPtnWP_502giuGONAQTB2GkauLalMfz3CqZmQ-CyxrRnlsWFs7knVaGv20laCWJf9qVcs_yrP4YR05VaVXW_iIPwAScSiQb7wZ07HTelU3l5JaMAvJbwI7LMjU1UpWpqbQ3wxbUpTh8eOUv1dvHMxEfO1kJ6oatWAmNo0gsNbxCeHiqkky71rUlmEKt5XmO0D67N7C0Ck9vAqPv6-XcQkQK7h47WPmMRU0nJR26pv6_FS3_DaxFmXXkKkGosJFlXPHFUgFaFBSiyhcGtaSYLuOpO3Yo_RY8qFxoCorA-5M6_4IjuNK9va9ONdgVJbCwlPqVmTYv1HQHxhJt6-ofn9KN8bJ6KTCEtoz7BAhQxnK_eWcPtwA2U172qkdifJSPbClTUGF5fvQjQv5eHECWKliuTbEYOtJBKu-upRiygCBFPWkDtIvKw75lM4bbGA0DF4lqtDLtufW0wGvwz5mzztZUQjTp7p99zyLs3CMasgi2GnKYbtNxCyW1IfFNJT3VYJyWTZ-tqDJJACIkCuxCF_20AEVUNuN0QjMF7wSLQ1oif4F3vvSOfHr3cCgVxeaGprkS05Y_zh5sn8LQp2aQu3VbW4d2qZ-J3hFZsR-7SIyXGn2WvOFI8eZEOCu7QCSl2cd4IicLtf-2xU_r4fxNQQp2_PTe0kH90GeB9h086p1l00Q33kn2Rv4RErV4gDWzmResR9Kp5vDEMUNjpomFGFfg0WPovx-9fBPye28ciRwyo9oFRob8ljZO5UgyTk9F6u-GxcUs4diRy3KV1thsn4jj8XnBTQvwc0Ut6AT6ILm3z_pSaRWafVa9U0y7OA=w1920-h868',
                  width: double.infinity,
                  height: 200.0,
                  fit: BoxFit.cover,
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
                          ischat ? Icons.bookmark : Icons.bookmark_border,
                          color: ischat ? Colors.blue : Colors.black,
                        ),
                        onPressed: togglechat,
                      ),
                      Text('$chatCount'),
                    ]
                ),

                Row(
                    children: <Widget>[
                      Text(
                          '댓글'
                      ),
                      Text(' 10'),
                    ]
                ),
                CommentWidget(author: '작성자 이름',
                  content: '댓글 내용',),
                CommentWidget(author: '작성자 이름',
                  content: '댓글 내용',),
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
                    // 댓글 입력 기능
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

class CommentWidget extends StatefulWidget {
  final String author;
  final String content;

  CommentWidget({required this.author, required this.content});

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  int likeCount = 10; // 댓글 초기 좋아요 수
  bool isLiked = false;

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.author}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text('${widget.content}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                        onPressed: toggleLike,
                      ),
                      Text('$likeCount'),
                    ]
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: StadiumBorder()
                  ),
                  onPressed: () {
                    // 대댓글
                  },
                  child: Text('답글'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
