import 'dart:convert';
import 'dart:io';


import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:kine/api/WebSocketProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';



class Message extends StatefulWidget {
  const Message({super.key});


  @override
  State<Message> createState() {
    return _Message();
  }
}



class _Message extends State<Message> {

  
  //final channel = IOWebSocketChannel.connect('wss://10.0.2.2:3000');

  String clientId = '';

  @override
  void initState() {
    super.initState();
    


  }

  @override
  void dispose() {
    super.dispose();

  }



  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final messages = webSocketProvider.messages;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WebSocket Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Client ID: $clientId'),
              IconButton(
                onPressed: () async {
                  // Exemple d'envoi d'un message au serveur
                  print('ok');
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  webSocketProvider.sendMessage(prefs.getString('token').toString(),'99', 'Hello from Flutter');
                  //WebSocketProvider().sendMessage(prefs.getString('token').toString(), 'Hello from Flutter');
                  //sendMessage(prefs.getString('token').toString(), 'Hello from Flutter');
                },
                icon: const Icon(
                  Icons.ice_skating
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
