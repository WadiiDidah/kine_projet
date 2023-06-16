
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kine/Introduction.dart';
import 'package:provider/provider.dart';
import 'ClassAll/Appointment.dart';
import 'LocalDatabase/DatabaseProvider.dart';
import 'LocalDatabase/RoleProvider.dart';
import 'PatientVue.dart';
import 'Profile/ListClient.dart';
import 'RDV/Calendrier.dart';
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
  late final DatabaseProvider databaseProvider;

  Appointment? recentapp;
  late var responseData = null;

  @override
  void initState()  {
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
    databaseProvider = DatabaseProvider();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await databaseProvider.open();
    recentapp =  await databaseProvider.getMostRecentRdvForPatient();
    setState(() {}); // Trigger a rebuild after obtaining the recentapp data
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
      title: "Home Page",
      home: Scaffold(
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              iconSection(context),
              lineSection,
              subTitleSection,
              //bottomSection,
              _buildCard(
                "ENATE CHARDONNAY 234",
                "\$9.98",
                "https://www.decantalo.com/fr/45554-product_img_dsk/domaine-matrot-bourgogne-chardonnay.jpg",
                "domaone",
                "cepage",
                "categorie",
                "Chateau",
                "commenataire",
                1,
                "",
              )
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          role: 'user',
          onTabSelected: _onTabSelected,
        ),
      ),
    );


  }

Widget boxSection = Container(
  width: double.infinity,
  padding: EdgeInsets.all(25),
  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigoAccent,
        Colors.indigo,
      ],
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Jing A studio',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      Text(
        'Tell me your dream',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
      SizedBox(height: 10),
      Text(
        'Invite friends to sell 1000 red packets',
        style: TextStyle(
          color: Colors.grey[200],
          fontSize: 15,
          fontWeight: FontWeight.w200,
        ),
      ),
      SizedBox(height: 10),
    ],
  ),
);

Widget containerSection = Container(
  height: 200,
  width: double.infinity,
  margin: EdgeInsets.all(20),
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue,
        Colors.green,
      ],
    ),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Titre',
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
      Text('Sous-titre'),
    ],
  ),
);

Widget rowSection = Container(
  color: Colors.black,
  height: 100,
  margin: EdgeInsets.all(20),
  child: Row(
    children: [
      Container(
        color: Colors.blue,
        height: 100,
        width: 100,
      ),
      Expanded(
        child: Container(
          color: Colors.amber,
        ),
      ),
      Container(
        color: Colors.purple,
        height: 100,
        width: 100,
      ),
    ],
  ),
);

void redirectToAutrePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DemoApp()),
  );
}

Widget iconSection(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: GestureDetector(
            onTap: () {
              print("tu as clické");
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ListeClient()));
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 5),
                Text('Profil')
              ],
            ),
          ),
        ),
        Container(
          child: GestureDetector(
            onTap: () {
              redirectToAutrePage(context);
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 5),
                Text('Rendez-vous')
              ],
            ),
          ),
        ),

        Container(
          child: GestureDetector(
            onTap: () {
              print("tu as clické");
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PatientVue()));
            },
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.data_thresholding_sharp,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 5),
                Text('Document')
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget lineSection = Container(
  color: Colors.grey[200],
  padding: EdgeInsets.all(4),
);

Widget subTitleSection = Container(
  margin: EdgeInsets.all(20),
  child: Row(
    children: [
      Container(
        color: Colors.redAccent,
        width: 5,
        height: 25,
      ),
      SizedBox(width: 10),
      Text(
        'Prochain rendez vous ',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      )
    ],
  ),
);

Widget bottomSection = Container(
  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
  child: Column(
    children: [
      Container(
        height: 130,
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 130,
              width: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigo,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Elite class',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Central Quing elite class',
                      style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Elite first choice rapid improuvmentof painting ability',
                      // choice rapid improuvmentof painting ability
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€53,000',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      Container(
        height: 130,
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 130,
              width: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange,
                    Colors.orange,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Design class',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Central Quing design class',
                      style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Elite first choice rapid improuvmentof painting ability',
                      // choice rapid improuvmentof painting ability
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€48,000',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

Widget _buildCard(
    String nom,
    String prix,
    String image,
    String domaine,
    String cepage,
    String categorie,
    String nomChateau,
    var commetaires,
    var id_post,
    var note,

    ) {
  return recentapp == null
      ? CircularProgressIndicator() // Show a progress indicator while data is loading
      :
  FutureBuilder(
      future: AuthService().getInfoKineByID(recentapp?.idkine),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Data is still loading
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error occurred while loading data
          print("recent kine id dleokdokoedodeokd" + recentapp!.idkine);
          return Text('Error loading data');
        } else {
          print("recent kine id " + recentapp!.idkine);

          // Data loaded successfully
          var responseData = json.decode(snapshot.data.toString());

          return Padding(
            padding: EdgeInsets.only(
                top: 3.0, bottom: 5.0, left: 5.0, right: 5.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3.0,
                      blurRadius: 5.0,
                    )
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                      ),
                    ),
                    const SizedBox(height: 7.0),
                     Text("${ recentapp?.dateTime ?? 'N/A'}",
                        style: TextStyle(
                            fontFamily: 'Varela',
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),

                    const SizedBox(height: 2.0),
                    Text("${ responseData?['name'] ?? 'N/A'}",
                        style: const TextStyle(
                            fontFamily: 'Varela',
                            fontSize: 19.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent)),
                    const SizedBox(height: 10.0),

                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.access_time, color: Colors.blue),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(" de ${ recentapp?.starthour ??
                              'N/A'} à ${ recentapp?.endhour ?? 'N/A'}",
                              style: const TextStyle(
                                  fontFamily: 'Varela',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                        const SizedBox(height: 10),
                        const Icon(Icons.calendar_month, color: Colors
                            .transparent),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.phone, color: Colors.blue),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text("num : ${responseData?['numtel'] ?? ''}",
                              style: const TextStyle(
                                  fontFamily: 'Varela',
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                        ),
                        const SizedBox(height: 10),
                        const Icon(Icons.calendar_month, color: Colors
                            .transparent),
                      ],

                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }
      }
  );
}
}