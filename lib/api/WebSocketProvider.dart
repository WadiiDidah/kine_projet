import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketProvider extends ChangeNotifier {
  //late final IOWebSocketChannel channel;
  IOWebSocketChannel? channel;
  List<String> messages = [];

  WebSocketProvider() {
    // Connect to the WebSocket server and start listening for messages
    _initializeWebSocketConnection();
  }

  Future<void> _initializeWebSocketConnection() async {
    await establishWebSocketConnection();
  }



  Future<void> establishWebSocketConnection() async {
    // Establish the WebSocket connection
    // ...
    print('establish web socket la');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final headers = {
      'Authorization': 'Bearer ${prefs.getString('token')}',
      'userId': '99',
    };

    // Initialize the 'channel' field
    // Connect to the WebSocket server
      channel = IOWebSocketChannel.connect(
          Uri.parse('wss://10.0.2.2:3000'),
          headers: headers
      ); // Connect to the WebSocket server);

    // Listen for incoming messages
    channel?.stream.listen((newMessage) {
        try {
          final data = jsonDecode(newMessage);
          final type = data['type'];
          final message = data['message'];
          print('Type: $type');
          print('Server response: $message');
          // Handle the received message as needed

          // Add the message to the list
          messages.add(message);

          // Notify listeners about the message update
          notifyListeners();
        } catch (error) {
          print('Error parsing message: $error');
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Handle WebSocket errors
      },
      onDone: () {
        print('WebSocket connection closed');
        // Handle WebSocket connection closed
      },
    );
  }

  void sendMessage(String token,String recipientId, String content) {
    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    final message = {
      'type': 'messagesend',
      'recipient': recipientId,
      'token': token,
      'content': content,
    };
    channel?.sink.add(jsonEncode(message));

  }



}
