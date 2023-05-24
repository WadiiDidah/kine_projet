import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../LocalDatabase/Conversation.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../api/WebSocketProvider.dart';
import '../CustomBottomNavigationBar.dart';
import 'ConversationDetailPage.dart';

class ConversationListPage extends StatefulWidget {
  final String role;

  const ConversationListPage({required this.role});

  @override
  _ConversationListPageState createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  int _currentIndex = 2;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }



  late final DatabaseProvider databaseProvider;
  late List<Conversation> conversations;

  @override
  void initState() {
    super.initState();
    databaseProvider = DatabaseProvider();
    conversations = [];
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    await databaseProvider.open();
    databaseProvider.addSampleData();
    final List<Conversation> fetchedConversations =
    await databaseProvider.getAllConversations();
    setState(() {
      conversations = fetchedConversations;
    });
  }

  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final messages = webSocketProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
        automaticallyImplyLeading: false, // Disable the automatic return arrow

      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            title: Text(conversation.userId),
            subtitle: Text(conversation.lastMessage),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ConversationDetailPage(conversation: conversation)),
              );

            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        role: 'kine',
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
