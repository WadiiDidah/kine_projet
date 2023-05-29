import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../ClassAll/Conversation.dart';
import '../ClassAll/Messages.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import 'authservice.dart';

class WebSocketProvider extends ChangeNotifier {
  //late final IOWebSocketChannel channel;
  IOWebSocketChannel? channel;
  List<Messages> messages = [];
  late final DatabaseProvider databaseProvider;


  WebSocketProvider() {
    // Connect to the WebSocket server and start listening for messages
    _initializeWebSocketConnection();
  }

  Future<void> _initializeWebSocketConnection() async {
    databaseProvider = DatabaseProvider();
    await databaseProvider.open();
    await establishWebSocketConnection();



  }



  Future<void> establishWebSocketConnection() async {
    // Establish the WebSocket connection
    // ...
    String myid = 'ok';

    print('establish web socket la');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await AuthService().getInfoUser(prefs.getString('token'));

    if (response != null) {
      final responseData = json.decode(response.toString());
      myid = responseData['id'];
      //print("mon id dans auth" + responseData['id']);
    }

    final headers = {
      'Authorization': 'Bearer ${prefs.getString('token')}',
      'userId': myid,
    };

    // Initialize the 'channel' field
    // Connect to the WebSocket server
      channel = IOWebSocketChannel.connect(
          Uri.parse('wss://10.0.2.2:3000'),
          headers: headers
      ); // Connect to the WebSocket server);


    // Listen for incoming messages
    channel?.stream.listen((newMessage) async {
        try {
          final data = jsonDecode(newMessage);

          // si le message envoyé est une demande de message direct
          if (data['type'] == "incomingmessage"){
            final type = data['type'];
            final recipient = data['recipient'];
            final sender = data['sender'];
            final content = data['content'];
            final sendername = data['sendername'];

            print('Type: $type');
            print('sendername: $sendername');
            print('sender: $sender');
            print('recipient: $recipient');
            print('Server response: $content');
            // Handle the received message as needed

            bool testIfExist = false;
            try{
              testIfExist =  await databaseProvider.isConversationExists(recipient, sender);
              print('booooooool : $testIfExist');
            }catch (error) {
              print('Error bool: $error');
            }


            // si la conversation existe deja, on ajoute seulement le message
            // en prenant l'id de la conversation
            if (testIfExist){
              int? idConv = await databaseProvider.getConversationId(recipient, sender);
              if (idConv != null) {
                print("Conversation ID: $idConv");
              } else {
                print("Conversation not found.");
              }

              if( idConv != null){
                final message = Messages(
                  conversationId: idConv,
                  senderId: sender,
                  content: content,
                  sentTime: DateTime.now(),
                );

                await databaseProvider.insertMessage(message);
                // Add the message to the list
                messages.add(message);
                notifyListeners();
              }else{
                print("id null");
              }

              // du coup la si la conversation n'est pas creer, on la creer
              // et on ajoute le message
            } else {

              print("conversation n'existe pas , alors on l'as crée");
              final conversation = Conversation(
                userId: recipient,
                name: sendername,
                otherUserId: sender,
                lastMessage: content,
                lastMessageTime: DateTime.now(),
              );

              //print("id conv" + conversation.id.toString());
              await databaseProvider.insertConversation(conversation);

              int? idConv = await databaseProvider.getConversationId(recipient, sender);
              if (idConv != null) {
                print("Conversation ID: $idConv");
              } else {
                print("Conversation not found.");
              }


              final message = Messages(
                conversationId: idConv!,
                senderId: sender,
                content: content,
                sentTime: DateTime.now(),
              );

              await databaseProvider.insertMessage(message);
              messages.add(message);
              notifyListeners();

            }


          }

          // Notify listeners about the message update
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
