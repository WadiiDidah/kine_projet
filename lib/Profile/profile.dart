import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';

import '../CustomBottomNavigationBar.dart';
import '../Introduction.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../LocalDatabase/RoleProvider.dart';
import '../api/WebSocketProvider.dart';
import '../api/authservice.dart';

class Profile extends StatefulWidget {
  final String role;


  const Profile({required this.role});


  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  bool _isEditing = false;

  late final RoleProvider roleProvider;

  late final DatabaseProvider databaseProvider;
  @override
  void initState() {
    super.initState();
    databaseProvider = DatabaseProvider();
    // Fetch user information and set the initial values of the controllers

    _initializeDatabase();


  }


  Future<void> _initializeDatabase() async {
    await databaseProvider.open();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if( prefs.getString('role') == "kine"){
      var response = await AuthService().getInfoUser(prefs.getString('token'));

      if (response != null) {
        final responseData = json.decode(response.toString());

        var respdata = await AuthService().getInfoKineByID(responseData['id']);

        final resp = json.decode(respdata.toString());


        _nameController.text = resp['name'];
        //_emailController.text = "responseData['mail']";
        _phoneController.text = resp['numtel'];
        //print("mon id dans auth" + responseData['id']);
      }
      setState(() {

      });
    } else {

      var response = await AuthService().getInfoUser(prefs.getString('token'));

      if (response != null) {
        final responseData = json.decode(response.toString());
        var respdata = await AuthService().getInfoUserByID(responseData['id']);

        final resp = json.decode(respdata.toString());


        _nameController.text = resp['name'];
        //emailController.text = "responseData['mail']";
        _phoneController.text = resp['numtel'];
        //print("mon id dans auth" + responseData['id']);
      }

        //print("mon id dans auth" + responseData['id']);
      }
    }



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  int _currentIndex = 1;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    // Save the changes made to the user information
    // Here you would typically update the data in your database
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Changes saved')),
    );
  }

  @override
  Widget build(BuildContext context) {

    final webSocketProvider = Provider.of<WebSocketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 64.0,
              backgroundImage: AssetImage('assets/icon.png'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phoneController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        role: widget.role,
        onTabSelected: _onTabSelected,
      ),
    );

  }
}


