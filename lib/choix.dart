import 'package:flutter/material.dart';
import 'formKine.dart';
import 'formPatient.dart';
import 'homeKine.dart';
class Choix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50.0),
                Text(
                  "Welcome",
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30.0),
                Center(child: Image(image: AssetImage("assets/officiel.png"))),
                SizedBox(height: 10.0),
                Center(
                    child: Text(
                      "Vous êtes kiné",
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),
                SizedBox(height: 10.0),
                Center(
                    child: Text(
                      "Cliquez sur le bouton",
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text('Kiné'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => FormKine(page:"kine")));
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 100, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 50.0),
                Center(
                    child: Text(
                      "Vous êtes patient",
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )),
                SizedBox(height: 10.0),
                Center(
                    child: Text(
                      "Cliquez sur le bouton",
                      style: TextStyle(
                        fontFamily: 'Varela',
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text('Patient'),
                      onPressed: () {
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => FormPatient(page:"patient")));
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => FormPatient(page: "patient")));

                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 100, vertical: 10),
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 150.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas de compte?",
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: Text(
                          "Créer maintenant",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                )
              ]),
        ),
      ),
    );
  }
}
