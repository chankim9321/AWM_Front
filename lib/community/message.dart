import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.nickname,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final String nickname;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) { //메시지 표시
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start, // 사용자 구분(왼,오)
        children: <Widget>[
          if (!isUser) // 상대방 닉네임 첫글자
            CircleAvatar(
              child: Text(nickname[0]),
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: isUser ? 20.0 : 5.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}