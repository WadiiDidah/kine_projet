
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kine/Introduction.dart';
import 'package:provider/provider.dart';
import 'LocalDatabase/DatabaseProvider.dart';
import 'LocalDatabase/RoleProvider.dart';
import 'api/WebSocketProvider.dart';
import 'api/authservice.dart';
import 'formKine.dart';
import 'formPatient.dart';
import 'homeKine.dart';
import'CustomBottomNavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';




class HomePatient extends StatefulWidget {
  final String role;

  const HomePatient({required this.role});

  @override
  _HomePatientState createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  static const String _title = 'Flutter OnePage Design';
  int _currentIndex = 0;


  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("onMessage:");
        print("onMessage: $message");
        final snackBar =
        SnackBar(content: Text(message.notification?.title ?? ""));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
    // TODO: implement initState
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    // Set the user's role
    roleProvider.setRole('user');

    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final messages = webSocketProvider.messages;


    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Colors.indigoAccent,
        automaticallyImplyLeading: false,

        actions: [
          IconButton(
              icon: const Icon(
                Icons.power_settings_new,
                size: 24,
              ),
              onPressed: () {
                DatabaseProvider().removeToken();
                DatabaseProvider().removeRole();
                webSocketProvider.channel?.sink.close();
                // Rediriger l'utilisateur vers l'écran de connexion
                Navigator.push(context, MaterialPageRoute(builder: (context) => Introduction()));
              }

            // Disconnect logic here
            // ...},
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        role: 'user',
        onTabSelected: _onTabSelected,
      ),
    );
  }


}

