import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'Introduction.dart';
import 'LocalDatabase/DatabaseProvider.dart';
import 'LocalDatabase/RoleProvider.dart';
import 'api/WebSocketProvider.dart';
import 'api/authservice.dart';
import 'formKine.dart';
import 'formPatient.dart';
import 'homeKine.dart';
import 'CustomBottomNavigationBar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeKine extends StatefulWidget {
  const HomeKine({required this.role});

  final String role;

  static const String _title = 'Flutter OnePage Design';

  @override
  _HomeKineState createState() => _HomeKineState();
}

class _HomeKineState extends State<HomeKine> {

  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) {
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
    roleProvider.setRole('kine');

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
          role: 'kine',
          onTabSelected: _onTabSelected,
        ),
    );
  }

}



