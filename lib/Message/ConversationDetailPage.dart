import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kine/api/WebSocketProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../LocalDatabase/Conversation.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../LocalDatabase/Messages.dart';

class ConversationDetailPage extends StatefulWidget {
  final Conversation conversation;

  const ConversationDetailPage({required this.conversation});

  @override
  _ConversationDetailPageState createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final TextEditingController _textEditingController = TextEditingController();
  late final DatabaseProvider databaseProvider;
  late List<String> messages;

  @override
  void initState() {
    super.initState();
    databaseProvider = DatabaseProvider();
    messages = [];
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    await databaseProvider.open();
    // Fetch messages for the conversation using conversation.id

    final List<Messages> fetchedMessages =
    await databaseProvider.getMessagesForConversation(widget.conversation.id);


    setState(() {
      messages = fetchedMessages.map((message) => message.content).toList();
    });
  }

  Future<void> _sendMessage(String message) async {
    final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);

    // Save the message to the database using conversation.id
    final newMessage = Messages(
      id: DateTime.now().microsecondsSinceEpoch,
      conversationId: widget.conversation.id,
      senderId: widget.conversation.userId,
      content: message,
      sentTime: DateTime.now(),
    );

    databaseProvider.insertMessage(newMessage);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('print token send${prefs.getString('token')}');

    webSocketProvider.sendMessage(prefs.getString('token').toString(), widget.conversation.otherUserId, message);

    setState(() {
      messages.add(message);
    });
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.userId),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
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
