import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../ClassAll/Patient.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../api/authservice.dart';
import 'Patient.dart';

class ListeClient extends StatefulWidget {
  const ListeClient ({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ListeClient > {

  late List<Patient> searchResults;

   List<Map<String, dynamic>> _allUsers = [];

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];


  late final DatabaseProvider databaseProvider;

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

    searchResults = [];
    _fetchUsers();
    _getAll();
  }

  void _fetchUsers() async {
    var response = await AuthService().getAllUSerInBdd();

    if (response != null) {
      print('response not null');
      final responseData = json.decode(response.toString());
      if (responseData['success']) {
        // Extract the list of users from the response
        final userList = responseData['users'];

        setState(() {
          _foundUsers = userList.map<Map<String, dynamic>>((user) => {
            "id": user['id'],
            "name": user['name'],
            "age": user['age'],
          }).toList();


        });

      } else {
        print("reponse fausse, rien trouvé");
      }
    } else {
      print("probleme avec la reponse");
    }
  }


  void _getAll() async {
    var response = await AuthService().getAllUSerInBdd();

    if (response != null) {
      print('response not null');
      final responseData = json.decode(response.toString());
      if (responseData['success']) {
        // Extract the list of users from the response
        final userList = responseData['users'];

        setState(() {
          _allUsers = userList.map<Map<String, dynamic>>((user) => {
            "id": user['id'],
            "name": user['name'],
            "age": user['age'],
          }).toList();
        });

      } else {
        print("reponse fausse, rien trouvé");
      }
    } else {
      print("probleme avec la reponse");
    }
  }


  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) =>
          user["name"].toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    setState(() {
      _foundUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des patients'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Rechercher', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _foundUsers.isNotEmpty
                  ? ListView.builder(
                itemCount: _foundUsers.length,
                itemBuilder: (context, index) => Card(
                  key: ValueKey(_foundUsers[index]["id"]),
                  color: Colors.grey,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/icon.png'),
                    ),
                    title: Text(_foundUsers[index]['name'],
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                        '${_foundUsers[index]["age"].toString()} years old',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      print(_foundUsers[index]['id']);
                      // Naviguer vers la page de description en passant l'ID en paramètre
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RootApp(user: _foundUsers[index]),),);
                    },
                  ),
                ),
              )

                  : const Text(
                'Aucun resultat trouvé',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}