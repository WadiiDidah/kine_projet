
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
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
  Widget build(BuildContext context) {

    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    // Set the user's role
    roleProvider.setRole('user');

    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final messages = webSocketProvider.messages;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
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
          role: widget.role,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }


}

