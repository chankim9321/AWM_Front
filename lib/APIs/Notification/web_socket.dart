import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String url;
  WebSocketChannel? _channel;
  StreamController<String> _streamController = StreamController<String>();

  WebSocketService(this.url){
    print("[Socket LOG] WebSocketService Created!");
    print("[Socket LOG] Socket Server Address: $url");
  }

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel?.stream.listen((message) {
      _streamController.add(message);
    }, onError: (error) {
      print('WebSocket Error: $error');
      _streamController.addError(error);
    }, onDone: () {
      print('WebSocket connection closed');
      _streamController.close();
    });
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel?.sink.add(message);
    } else {
      print('WebSocket is not connected.');
    }
  }

  Stream<String> get messages => _streamController.stream;

  void disconnect() {
    _channel?.sink.close();
    _streamController.close();
  }
}
