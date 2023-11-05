import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/community/content.dart';
import 'package:mapdesign_flutter/community/write.dart';

class search extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.search,
                color: Colors.white,
              ),
              SizedBox(
                width: 8,
              ),
              Flexible(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      border: InputBorder.none,
                      hintText: '검색 키워드를 입력해주세요',
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
            ],
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () {
                // 스크랩 아이콘을 눌렀을 때의 동작 추가
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // 알림 아이콘을 눌렀을 때의 동작 추가
              },
            ),
          ],
        ),
        body: SearchWidget(),


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
              icon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
          onTap: (int index) {
            if (index == 1) {
             Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddPostPage()
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return CommunityPost();
                }
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityPost extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 게시물을 터치했을 때 수행할 동작 정의
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailScreen()),
        );
      },

      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        //margin: EdgeInsets.all(10.0),
        //padding: EdgeInsets.all(10.0),
        //|padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '게시물 제목',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.network(
                  //'https://static.wikia.nocookie.net/pokemon/images/a/aa/%EC%82%90_%EA%B3%B5%EC%8B%9D_%EC%9D%BC%EB%9F%AC%EC%8A%A4%ED%8A%B8.png/revision/latest/scale-to-width-down/200?cb=20170406071411&path-prefix=ko',
                  'https://lh3.googleusercontent.com/fife/AK0iWDzQiPOTWGjc3CJEo_D762eA1DXRWUDxdhtonJwZriX6OQqS_p3rfLMG-h3Z7nuMWiJuvxs9S-WHvL1OnIbCwpWBmI-A3UtaXaXlPJzPqFbgJY6Sp2IN--EtOv_wRlYadwmtWwAIrjDJB_Jx1IKew5B71yTjBL4zgN0GK9-We_GaUWkFRGl9NxFkMDNrmkah3f4DSF7-QlT6gDKn1ynNpUGkfmVJ8wPz0R1SxArTpZlkhaMkd7i9CBcOmAX445TJ6s4b5umF2p-apvhWgJdVDAm1cR6bPKLnforY03YOfm0fqoqAb73YNIJpTdxqlmjQc7UMca0rRkV3R_JgIG6RZg7169q_lFJvhki9idnRm0JNDkgTyENI3cV5zYLtHN5X1gw2txek-6FYCwijTPnuWIo_x-HBtiR2I1npJjSiR0st3GgvhaeaUt4-xJCKywQqf4iFJA9I94IVt9oqYZraFUna1JXLqUpA3vCXCBSeALmQ7sQrses3I8CSMOeY_nKG2RSAxcu5jAib6jmvlb84QS9k_0F2Wti7kOKuABmTEfsFUnTpyc4KpdNktzEY7wwTYLigQmb0fh7Lrg9GAOWV4wz3eLlVPqjcLxCWDte5O2tBN9CAPL3dM3gazpgcvf3AwQq7o_2-xrrCzaACr-7GqItL8Tc0qCn35BXDdEqOhyjfa6cp2IRpZB3g03Gb_rzf_XqdWX5XEJWRY3b-0XPtnWP_502giuGONAQTB2GkauLalMfz3CqZmQ-CyxrRnlsWFs7knVaGv20laCWJf9qVcs_yrP4YR05VaVXW_iIPwAScSiQb7wZ07HTelU3l5JaMAvJbwI7LMjU1UpWpqbQ3wxbUpTh8eOUv1dvHMxEfO1kJ6oatWAmNo0gsNbxCeHiqkky71rUlmEKt5XmO0D67N7C0Ck9vAqPv6-XcQkQK7h47WPmMRU0nJR26pv6_FS3_DaxFmXXkKkGosJFlXPHFUgFaFBSiyhcGtaSYLuOpO3Yo_RY8qFxoCorA-5M6_4IjuNK9va9ONdgVJbCwlPqVmTYv1HQHxhJt6-ofn9KN8bJ6KTCEtoz7BAhQxnK_eWcPtwA2U172qkdifJSPbClTUGF5fvQjQv5eHECWKliuTbEYOtJBKu-upRiygCBFPWkDtIvKw75lM4bbGA0DF4lqtDLtufW0wGvwz5mzztZUQjTp7p99zyLs3CMasgi2GnKYbtNxCyW1IfFNJT3VYJyWTZ-tqDJJACIkCuxCF_20AEVUNuN0QjMF7wSLQ1oif4F3vvSOfHr3cCgVxeaGprkS05Y_zh5sn8LQp2aQu3VbW4d2qZ-J3hFZsR-7SIyXGn2WvOFI8eZEOCu7QCSl2cd4IicLtf-2xU_r4fxNQQp2_PTe0kH90GeB9h086p1l00Q33kn2Rv4RErV4gDWzmResR9Kp5vDEMUNjpomFGFfg0WPovx-9fBPye28ciRwyo9oFRob8ljZO5UgyTk9F6u-GxcUs4diRy3KV1thsn4jj8XnBTQvwc0Ut6AT6ILm3z_pSaRWafVa9U0y7OA=w1920-h868',
                  width: 150,
                  height: 100,
                ),
              ],
            ),
            Text('게시물 내용'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(Icons.thumb_up_outlined),
                SizedBox(width: 8),
                Text('10'),
                SizedBox(width: 8),

                Icon(Icons.chat_bubble_outline),
                SizedBox(width: 8),
                Text('10'),
              ],
            ),
            Divider(height:50, color: Colors.black, thickness: 2.0)
          ],
        ),
      ),
    );
  }
}

