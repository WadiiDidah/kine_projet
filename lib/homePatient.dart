
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'LocalDatabase/RoleProvider.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Home Page",
          ),
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

