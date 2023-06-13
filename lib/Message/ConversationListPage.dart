import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ClassAll/Conversation.dart';
import '../ClassAll/Patient.dart';
import '../Introduction.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../LocalDatabase/RoleProvider.dart';
import '../api/WebSocketProvider.dart';
import '../CustomBottomNavigationBar.dart';
import '../api/authservice.dart';
import 'ConversationDetailPage.dart';

class ConversationListPage extends StatefulWidget {
  final String role;


  const ConversationListPage({required this.role});

  @override
  _ConversationListPageState createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  int _currentIndex = 2;
  String myid = 'ok';

  TextEditingController _searchController = TextEditingController();

  late SharedPreferences prefs;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }





  late List<Patient> searchResults;
  late final DatabaseProvider databaseProvider;
  late List<Conversation> conversations;
  late final RoleProvider roleProvider;

  bool isSearchResultsVisible = false; // Track the visibility of search results




  void _handleConversation(Patient user) async {

    //await databaseProvider.open();

    Future<bool> testIfExist =  databaseProvider.isConversationExists(myid, user.id);

    if (await testIfExist){
      Fluttertoast.showToast(
        msg: "La conversation existe deja dans votre repertoire",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        textColor: Colors.red
      );
    } else {
      final conversation = Conversation(
        userId: myid,
        name: user.name,
        otherUserId: user.id,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      );
      await databaseProvider.insertConversation(conversation);

      // Get the conversation ID
      int? idConv = await databaseProvider.getConversationId(myid, user.id);
      if (idConv != null) {
        print("Conversation ID: $idConv");

        // Pass the conversation ID to the ConversationDetailPage
        conversation.id = idConv;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationDetailPage(
              conversation: conversation,
              myUserID: myid,
              nameotherpeople: user.name,
            ),
          ),
        );
      } else {
        print("Conversation not found.");
      }

    }






  }

  void _performSearch(String searchQuery) async {
    // Call the AuthService().getAllPatient() function with the search query
    // Pass the search query to the server-side and handle the response
    var response = await AuthService().getAllPatient(searchQuery);

    if (response != null) {
      print('response not null');
      final responseData = json.decode(response.toString());
      if(responseData['success']){
        // Extract the list of users from the response
        final userList = responseData['users'];

        searchResults = userList.map<Patient>((user) => Patient.fromMap(user)).toList();
      } else {
        print("reponse fausse, rien trouvé");
      }


      //print("mon id dans auth" + responseData['id']);
    }else{
      print("probleme avec la reponse");
    }


  }

  @override
  void initState()  {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage:");
      print("onMessage: $message");
      final snackBar =
      SnackBar(content: Text(message.notification?.title ?? ""));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    },
    );
    super.initState();
    databaseProvider = DatabaseProvider();
    conversations = [];
    searchResults = [];
    roleProvider = Provider.of<RoleProvider>(context, listen: false);

    // Set the user's role
    print("le role ${roleProvider.role}");

    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    prefs = await SharedPreferences.getInstance();

    var response = await AuthService().getInfoUser(prefs.getString('token'));

    if (response != null) {
      final responseData = json.decode(response.toString());
      myid = responseData['id'];
      //print("mon id dans auth" + responseData['id']);
    }

    await databaseProvider.open();
    //databaseProvider.addSampleData();
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Message",
            ),
            CupertinoButton(
              child: const Icon(
                CupertinoIcons.power,
                size: 24,
              ),
              onPressed: () {
                DatabaseProvider().removeToken();
                webSocketProvider.channel?.sink.close();
                // Rediriger l'utilisateur vers l'écran de connexion
                Navigator.push(context, MaterialPageRoute(builder: (context) => Introduction()));
              },
            ),
          ],
        ),
        centerTitle: true,
        elevation: 10,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) async {
                  if (value.isNotEmpty) {
                    // Call the search function when the search query changes
                    _performSearch(value);


                    setState(() {
                      isSearchResultsVisible = true;
                    });
                  } else {
                    setState(() {
                      isSearchResultsVisible = false;
                    });
                  }
                },
              ),
          ),
          Visibility(
            visible: isSearchResultsVisible,
              child: Expanded(
              child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text(user.name,
                      style: const TextStyle(
                        fontSize: 18, // Customize the font size
                        fontWeight: FontWeight.bold, // Add font weight if desired
                      ),
                    ),

                      onTap: () {
                        _handleConversation(user);
                      // Handle the user selection
                      // You can navigate to a conversation page or perform other actions
                      // based on the selected user.
                      },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final name = conversation.name ; // Add a null check for the name property
                return ListTile(
                  title: Text(name),
                 // subtitle: Text(conversation.otherUserId),
                  onTap: () {
                    // ...
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ConversationDetailPage(conversation: conversation, myUserID: myid, nameotherpeople: conversation.name))
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        role: roleProvider.role,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}


