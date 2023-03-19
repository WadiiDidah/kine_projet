import 'package:flutter/material.dart';
import 'choix.dart';

class Introduction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerMove: (moveEvent) {
          if (moveEvent.delta.dx > 0)
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Choix()));


        },
        child: Container(
          decoration: new BoxDecoration(color: Colors.blue),
          child: new Center(
            child: Image(image: AssetImage("assets/officiel.png")),
          ),
        ));
  }
}
