import 'package:flutter/material.dart';

enum SampleItem { itemOne, itemTwo, itemThree }

class CommentWidget extends StatefulWidget {
  final String author;
  final String content;
  final Function(CommentWidget) onCommentAdded; // Callback function

  List<CommentWidget> replyComments = [];

  CommentWidget({
    required this.author,
    required this.content,
    required this.onCommentAdded,
  });

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  int likeCount = 0; // 초기 좋아요 수
  bool isLiked = false;
  SampleItem? selectedMenu;
  bool isReplying = false;
  TextEditingController replyController = TextEditingController();

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

  void replyToComment() {
    setState(() {
      if (isReplying) {
        // 저장된 대댓글 목록에 새로운 대댓글 추가
        CommentWidget newReply = CommentWidget(
          author: '대댓글 작성자',
          content: replyController.text,
          onCommentAdded: widget.onCommentAdded, // Pass the callback
        );

        // Notify the parent widget about the new comment
        widget.onCommentAdded(newReply);

        // Update the state
        widget.replyComments.add(newReply);

        // 리플라이 입력 필드 비우고 대댓글 작성 모드 종료
        replyController.text = '';
        isReplying = false;
      } else {
        isReplying = true;
      }
    });
  }

  int chatCount = 0; // 초기 댓글 수
  bool ischat = false;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.author}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    PopupMenuButton<SampleItem>(
                      initialValue: selectedMenu,
                      // Callback that sets the selected popup menu item.
                      onSelected: (SampleItem item) {
                        setState(() {
                          selectedMenu = item;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<SampleItem>>[
                        const PopupMenuItem<SampleItem>(
                          value: SampleItem.itemOne,
                          child: Text('댓글 신고'),
                        ),
                      ],
                    ),
                  ],
                ),
                Text('${widget.content}'),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  onPressed: replyToComment,
                  child: Text('답글'),
                ),
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
                  ],
                ),
              ],
            ),
            if (isReplying)
              TextField(
                controller: replyController,
                decoration: InputDecoration(
                  hintText: '대댓글을 입력하세요',
                ),
              ),
            if (widget.replyComments.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.replyComments.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: reply,
                  );
                },
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
