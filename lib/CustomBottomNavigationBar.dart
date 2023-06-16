import 'package:flutter/material.dart';
import 'package:kine/Message/ConversationListPage.dart';
import 'package:kine/Profile/profile.dart';
import 'package:kine/RDV/AppointmentsKinePage.dart';
import 'package:kine/RDV/AppointmentsPage.dart';
import 'package:kine/homeKine.dart';
import 'package:kine/homePatient.dart';
import 'package:provider/provider.dart';

import 'LocalDatabase/RoleProvider.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final String role;
  final Function(int) onTabSelected;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.role,
    required this.onTabSelected,
  });

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {

  void _onTabTapped(int index) {
    // Call the onTabSelected callback provided by the parent widget
    widget.onTabSelected(index);

    // Handle page navigation based on the selected tab index and role
    if (widget.role == 'user') {
      if (index == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePatient(role: 'user')));
      } else if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile(role: 'user')));
      } else if (index == 2) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ConversationListPage(role: 'user')));
      }else if (index == 3) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  AppointmentsPage()));

      }
    } else if (widget.role == 'kine') {
      if (index == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeKine(role: 'kine')));
      } else if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  const Profile(role: 'kine')));
      } else if (index == 2) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ConversationListPage(role: 'kine')));
      }else if (index == 3) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  AppointmentsKinePage()));
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context);

    // Access the user's role
    String role = roleProvider.role;
    return BottomNavigationBar(

      currentIndex: widget.currentIndex,
      onTap: _onTabTapped,
      items: _buildNavigationItems(),
      backgroundColor: Colors.white, // Set the background color
      selectedItemColor: Colors.indigoAccent, // Set the selected item color
      unselectedItemColor: Colors.grey, // Set the unselected item color
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    if (widget.role == 'user') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'People',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Message',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
      ];
    } else if (widget.role == 'kine') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'People',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: 'Message',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
      ];
    } else {
      return [];
    }
  }
}
