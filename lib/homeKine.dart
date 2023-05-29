import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: HomeKine._title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Home Page",
          ),
          centerTitle: true,
          elevation: 10,
          backgroundColor: Colors.indigoAccent,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),


            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          role: 'kine',
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }

}




