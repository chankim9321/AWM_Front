import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final WebSocketChannel channel;

  WebSocketService(String url)
      : channel = IOWebSocketChannel.connect(url);

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  Stream<String> get messages => channel.stream.map((event) => event.toString());

  void close() {
    channel.sink.close();
  }
}
