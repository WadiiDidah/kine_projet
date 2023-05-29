import 'package:flutter/material.dart';
import 'package:kine/homeKine.dart';
import 'choix.dart';
import 'rendezVous.dart';

class BottomBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BottomBar();
  }
}

class _BottomBar extends State<BottomBar> with SingleTickerProviderStateMixin {
  bool connecte = false;
  var role;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      color: Colors.transparent,
      elevation: 9.0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0)),
            color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.home),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => HomeKine()));
                    },
                  ),
                  new IconButton(
                    icon: new Icon(Icons.chat_bubble),
                    color: Color(0xFF676E79),
                    onPressed: () async {},
                  ),
                  new IconButton(
                    icon: new Icon(Icons.calendar_month),
                    color: Color(0xFF676E79),
                    onPressed: () async {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DemoApp()));
                    },
                  ),
                  if (connecte == false)
                    new IconButton(
                      icon: new Icon(Icons.logout_sharp),
                      color: Color(0xFF676E79),
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Choix()));
                      },
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
