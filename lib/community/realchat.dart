import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mapdesign_flutter/APIs/backend_server.dart';

//import 'package:web_socket_channel/stomp.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Chat App',
      home: ChatScreen(),
    );
  }
}
String baseUrl = '${ServerConf.url}';
class ChatScreen extends StatelessWidget {
  //final String baseUrl = 'https://d671-211-224-31-97.ngrok-free.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Chat Room'),
      ),
      body: ChatRoom(),
    );
  }
}

class ChatRoom extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final roomIdController = useTextEditingController();
    //final channel = IOWebSocketChannel.connect('ws://6f93-112-220-77-99.ngrok-free.app/chat/${roomIdController}');

    return Column(
      children: [
        TextField(
          controller: roomIdController,
          decoration: InputDecoration(
            labelText: 'Enter Room ID',
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final roomId = roomIdController.text;
            final roomExists = await checkIfRoomExists(roomId);
            if (!roomExists) {
              await createChatRoom(roomId);
            }

            enterChatRoom(context, roomId);
          },
          child: Text('Enter Chat Room'),
        ),
        /*StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
            );
          },
        ),*/
      ],
    );
  }

  Future<bool> checkIfRoomExists(String roomId) async {
    final response = await http.post(Uri.parse('https://${baseUrl}/chat/room?roomId=$roomId'));

    return response.statusCode == 200;
  }

  Future<void> createChatRoom(String roomId) async {
    final response = await http.post(Uri.parse('https://$baseUrl/chat/rooms'), body: {'roomId': roomId});

    if (response.statusCode != 200) {
      throw Exception('Failed to create chat room');
    }
  }

  Future<void> enterChatRoom(BuildContext context, String roomId) async {
    // Implement navigation to the chat room
    // You can use Navigator.push to navigate to the chat room page
    print('입장');
    //final channel = IOWebSocketChannel.connect('ws://6f93-112-220-77-99.ngrok-free.app/chat/$roomId');
    final response = await http.get(Uri.parse('https://$baseUrl/chat/room/enter/${roomId}'));
    print('입장 상태코드');
    print(response.statusCode);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomPage(baseUrl: 'https://${baseUrl}', roomId: roomId),
        ),
      );
    }
    else if (response.statusCode != 200) {
      print('입장 못함');
      throw Exception('Failed to create chat room');
    }

  }
}

class ChatRoomPage extends StatefulWidget {
  final String baseUrl;
  final String roomId;

  ChatRoomPage({required this.baseUrl, required this.roomId});

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late IOWebSocketChannel channel;

  //late WebSocketChannel channel;
  //late WebSocketChannel sendchannel;
  //late WebSocketChannel connectionChannel;
  //late WebSocketChannel messageChannel;

  final TextEditingController messageController = TextEditingController();
  late List<String> chatMessages;
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  void showConnectionSuccessSnackBar() {
    showSnackBar('*'*70);
    showSnackBar('WebSocket connection established successfully!');
  }
  void showMessageSentSnackBar() {
    showSnackBar('*'*80);
    showSnackBar('Message sent successfully!');
  }
  @override
  void initState() {
    super.initState();
    // Connect to the WebSocket when the page is created
    print('연결코드 들어옴');
    channel = IOWebSocketChannel.connect('ws://${ServerConf.url}/connection');
    print('연결코드 나옴');
    //connectionChannel = IOWebSocketChannel.connect('ws://17c1-211-224-31-97.ngrok-free.app/connection');

    // Initialize chatMessages list
    chatMessages = [];

    // Connect to the WebSocket for messages
    //messageChannel = IOWebSocketChannel.connect('ws://17c1-211-224-31-97.ngrok-free.app/app/chat/message');


    // Listen for incoming messages from the server
    channel.stream.listen((message) {
      print('Received message: $message');
      // Handle the incoming message, e.g., update the UI with the new message
      setState(() {
        chatMessages.add(message);
      });
    });
    /*messageChannel.stream.listen((message) {
      print('Received message: $message');
      // Handle the incoming message, e.g., update the UI with the new message
      setState(() {
        chatMessages.add(message);
        showMessageSentSnackBar(); // Show snackbar for successful message sending
      });
    });*/
  }

  /*void sendMessage() {
    // ... (unchanged)

    // Clear the message input field
    messageController.clear();
  }*/
  /*void sendMessage() {
    final message = messageController.text.trim();

    if (message.isNotEmpty) {
      final messageData = {
        'roomId': widget.roomId,
        'nickname': 'YourNickname', // Replace with the actual nickname logic
        'time': DateTime.now().toIso8601String(),
        'message': message,
      };

      // Send the message to the server
      channel.sink.add(jsonEncode(messageData));
      print('보냄아마');
      // Clear the message input field
      messageController.clear();
    }
  }*/

  void sendMessage() {

    //sendchannel = IOWebSocketChannel.connect('ws://17c1-211-224-31-97.ngrok-free.app/chat/message');

    final message = messageController.text.trim();
    print('보낼 메시지');
    print(message);

    if (message.isNotEmpty) {
      final messageData = {
        'roomId': widget.roomId,
        'nickname': 'YourNickname', // Replace with the actual nickname logic
        'time': DateTime.now().toIso8601String(),
        'message': message,
      };
      print('messageData');
      print(messageData);
      print(jsonEncode(messageData));
      //sendchannel.sink.add(jsonEncode(messageData));

      //messageController.clear();
      // Send the message to the server through WebSocket
      /*channel.sink.add(jsonEncode(messageData));
      print('Message sent to WebSocket server');
      // Clear the message input field
      messageController.clear();*/
      print('전송 들어감');
      //IOWebSocketChannel messageChannel = IOWebSocketChannel.connect('ws://d671-211-224-31-97.ngrok-free.app/chat/message');

      //IOWebSocketChannel messageChannel = IOWebSocketChannel.connect('ws://${baseUrl}/chat/message');
      print('전송 나옴');

      channel.sink.add(jsonEncode(messageData));
      //channel.sink.close();
      messageController.clear();

    }
  }

  /*void sendMessage() async {
    // Get the message from the text field
    String message = messageController.text;

    // Check if the message is not empty
    if (message.isNotEmpty) {
      try {
        // Construct the JSON data
        Map<String, dynamic> messageData = {
          'roomId': widget.roomId,
          'nickname': 'YourNickname', // Replace with the actual nickname logic
          'time': DateTime.now().toIso8601String(),
          'message': message,
        };

        // Send the JSON data to the server using HTTP POST request
        final response = await http.post(
          Uri.parse('$baseUrl/app/chat/message'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(messageData),
        );
        print(jsonEncode(messageData));
        print('$baseUrl/app/chat/message');
        // Check if the request was successful (status code 200)
        if (response.statusCode == 200) {
          // Clear the text field after sending the message
          messageController.clear();

          // Optionally, update the UI to show the sent message immediately
          setState(() {
            chatMessages.add(jsonEncode(messageData));
          });

          // Show a snackbar indicating successful message sending
          showMessageSentSnackBar();
        } else {
          // Handle the case where the server did not respond with a 200 status code
          print('Failed to send message. Status code: ${response.statusCode}');
          // Optionally, show an error snackbar or perform other error handling
        }
      } catch (e) {
        // Handle any exceptions that may occur during message sending
        print('Error sending message: $e');
        // Optionally, show an error snackbar or perform other error handling
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room: ${widget.roomId}'),
      ),
      body: Column(
        children: [
          // Removed StreamBuilder from here
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(chatMessages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () => sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Close the WebSocket connection when the page is disposed
    //channel.sink.close();
    //connectionChannel.sink.close();
    //messageChannel.sink.close();
    channel.sink.close();
    super.dispose();
  }
}
