import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kine/Message/ConversationListPage.dart';
import 'package:kine/api/WebSocketProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ClassAll/Conversation.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../ClassAll/Messages.dart';
import '../LocalDatabase/RoleProvider.dart';
import '../api/authservice.dart';

class ConversationDetailPage extends StatefulWidget {
  final Conversation conversation;
  final String myUserID;
  final String nameotherpeople;

  const ConversationDetailPage({required this.conversation, required this.myUserID, required this.nameotherpeople});

  @override
  _ConversationDetailPageState createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final TextEditingController _textEditingController = TextEditingController();
  late final DatabaseProvider databaseProvider;
  late List<String> messages;
  late List<Messages> fetchedMessages;

  @override
  void initState() {
    super.initState();
    databaseProvider = DatabaseProvider();

    messages = [];
    fetchedMessages = [];
    _initializeDatabase();

    _fetchMessages();


    // Subscribe to WebSocketProvider message updates
    final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);
    webSocketProvider.addListener(_fetchMessages);
  }

  Future<void> _initializeDatabase() async {
    await databaseProvider.open();
  }

  Future<void> _fetchMessages() async {
    await _initializeDatabase();
    if (mounted) {
      print("LA CA EXECUTE PEUT ETRE EN LISTENER" );




      // Fetch messages for the conversation using conversation.id

      fetchedMessages = await databaseProvider.getMessagesForConversation(widget.conversation.id!);


      setState(()  {
        messages = fetchedMessages.map((message) => message.content).toList();
      });
    }

  }

  Future<void> _sendMessage(String message) async {
    final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);


    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('print token send${prefs.getString('token')}');

    // Save the message to the database using conversation.id
    final newMessage = Messages(
      id: DateTime.now().microsecondsSinceEpoch,
      conversationId: widget.conversation.id!,
      senderId: widget.myUserID,
      content: message,
      sentTime: DateTime.now(),
    );

    databaseProvider.insertMessage(newMessage);

    webSocketProvider.sendMessage(prefs.getString('token').toString(), widget.conversation.otherUserId, message);

    setState(() {
      fetchedMessages.add(newMessage);
      //messages.add(message);
    });
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {

    final roleProvider = Provider.of<RoleProvider>(context, listen: false);


    // Set the user's role
    print("le role ${roleProvider.role}");

    final name = widget.nameotherpeople ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(

        title: Text(name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ConversationListPage(role: roleProvider.role)),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: fetchedMessages.length,
              itemBuilder: (context, index) {
                final message = fetchedMessages[index];
                final isCurrentUser = message.senderId == widget.myUserID;

                return Row(
                  mainAxisAlignment:
                  isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final message = _textEditingController.text;
                    _sendMessage(message);
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
