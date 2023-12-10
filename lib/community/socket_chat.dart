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
  StompClient? stompClient; //stomp통신
  TextEditingController _textController = TextEditingController(); //메세지
  List<ChatMessage> _messages = [];

  @override
  void initState() { //먼저 초기화
    super.initState();
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://${ServerConf.url}/connection',
        onWebSocketError: (dynamic error) => print(error.toString()),
        onDisconnect: (dynamic state) => print(state.toString()),
        onConnect: onConnect, // 메시지 받아옴
        //onDisconnect: onDisconnect,
      ),
    );
    if(stompClient == null){
      CustomDialog.showCustomDialog(context, "연결 실패", "서버와의 접속이 끊겼습니다.");
      Navigator.pop(context);
    }
    else{
      stompClient!.activate();
      if(stompClient!.isActive){
        print("세션 활성화");
      }
    } //연결
  }
  Widget _buildTextComposer() { //전송
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
                ),
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
  void _handleSubmitted(String text) { //전송 메시지
    print('send enter');
    _textController.clear();
    stompClient!.send( // 보낼 메시지
      destination: '/app/chat/message',
      body: jsonEncode({
        'roomId' : '${widget.locationId}',
        'nickName': widget.nickName,
        'message': text,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }
  void onConnect(StompFrame frame) { // 메시지 수신
    print('Connected: ${frame.body}');
    stompClient?.subscribe(
      destination: '/topic/chat/room/${widget.locationId}',
      callback: (StompFrame frame) {
        print('Received: ${frame.body}');
        // Process received message and update UI
        _handleReceivedMessage(frame.body!);
      },
    );
  }
  void _handleReceivedMessage(String text) { //받는 메시지
    // Process received message and update UI
    Map<String, dynamic> messageData = jsonDecode(text);
    String roomId = messageData['roomId'];
    String nickname = messageData['nickName'];
    String messageText = messageData['message'];
    DateTime timestamp = DateTime.parse(messageData['timestamp']);
    bool? isUser;
    if(widget.nickName==nickname){ // 본인이라면
      isUser = true;
    }else if(widget.nickName!=nickname){ // 본인이 아니라면
      isUser = false;
    }
    ChatMessage message = ChatMessage(
      text: messageText,
      isUser: isUser!,
      nickname: nickname,
      timestamp: timestamp,
    );
    setState(() {
      _messages.insert(0, message); // 메시지 추가
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
        title: Text('채팅방'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              reverse: true, //밑에서 위로
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Divider(height: 1.0), //구분선
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

