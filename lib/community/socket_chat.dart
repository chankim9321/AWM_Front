import 'package:flutter/material.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'dart:convert';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/community/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.nickName = '익명', required this.locationId});
  final String nickName;
  final int locationId;
  @override
  State createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  StompClient? stompClient;
  TextEditingController _textController = TextEditingController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://${ServerConf.url}/chat/connection',
        onWebSocketError: (dynamic error) => print(error.toString()),
        onDisconnect: (dynamic state) => print(state.toString()),
        onConnect: onConnect,
      ),
    );
    if (stompClient == null) {
      CustomDialog.showCustomDialog(context, "연결 실패", "서버와의 접속이 끊겼습니다.");
      Navigator.pop(context);
    } else {
      stompClient!.activate();
      if (stompClient!.isActive) {
        print("세션 활성화");
      }
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).primaryColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration.collapsed(
                  hintText: '메시지를 입력하세요.',
                  hintStyle: TextStyle(fontFamily: 'PretendardLight'),
                ),
                style: TextStyle(fontFamily: 'PretendardLight'),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    stompClient!.send(
      destination: '/app/chat/message',
      body: jsonEncode({
        'roomId': '${widget.locationId}',
        'nickName': widget.nickName,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  void onConnect(StompFrame frame) {
    stompClient?.subscribe(
      destination: '/topic/chat/room/${widget.locationId}',
      callback: (StompFrame frame) {
        _handleReceivedMessage(frame.body!);
      },
    );
  }

  void _handleReceivedMessage(String text) {
    Map<String, dynamic> messageData = jsonDecode(text);
    String roomId = messageData['roomId'];
    String nickname = messageData['nickName'];
    String messageText = messageData['message'];
    DateTime timestamp = DateTime.parse(messageData['timestamp']);
    bool isUser = widget.nickName == nickname;

    ChatMessage message = ChatMessage(
      text: messageText,
      isUser: isUser,
      nickname: nickname,
      timestamp: timestamp,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅방',
          style: TextStyle(fontFamily: 'PretendardLight', color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.isUser, required this.nickname, required this.timestamp});

  final String text;
  final bool isUser;
  final String nickname;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isUser ? _userMessage(context) : _otherMessage(context),
      ),
    );
  }

  List<Widget> _userMessage(BuildContext context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              nickname,
              style: TextStyle(fontFamily: 'PretendardLight', fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                text,
                style: TextStyle(fontFamily: 'PretendardLight'),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 8.0),
      CircleAvatar(
        child: Text(nickname[0]),
      ),
    ];
  }

  List<Widget> _otherMessage(BuildContext context) {
    return <Widget>[
      CircleAvatar(
        child: Text(nickname[0]),
      ),
      SizedBox(width: 8.0),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              nickname,
              style: TextStyle(fontFamily: 'PretendardLight', fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                text,
                style: TextStyle(fontFamily: 'PretendardLight'),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
