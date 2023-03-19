import 'package:flutter/material.dart';
import 'formKine.dart';
import 'formPatient.dart';
import 'homeKine.dart';
import'bottomBar.dart';

class HomeKine extends StatelessWidget {
  static const String _title = 'Flutter OnePage Design';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
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
              iconSection,
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
                  "")
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }
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

Widget iconSection = Container(
  padding: EdgeInsets.all(10),
  margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
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
            Text('Patients')
          ],
        ),
      ),
      Container(
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
      Container(
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
            Text('Documents')
          ],
        ),
      ),
    ],
  ),
);

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
    var note) {
  return Padding(
    padding: EdgeInsets.only(top: 3.0, bottom: 5.0, left: 5.0, right: 5.0),
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
            SizedBox(height: 7.0),
            Text("Aujord'hui",
                style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Hero(
              tag: prix,
              child: Container(
                height: 150.0,
                width: 100,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/icon.png"),
                        fit: BoxFit.contain)),
              ),
            ),
            SizedBox(height: 2.0),
            Text("Rendez vous avec joe Elik",
                style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 19.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent)),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.calendar_month, color: Colors.blue),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(" 23 Février 2023",
                      style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                SizedBox(height: 10),
                Icon(Icons.calendar_month, color: Colors.transparent),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.access_time ,color: Colors.blue),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(" 8 :17AM             ",
                      style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                SizedBox(height: 10),
                Icon(Icons.calendar_month, color: Colors.transparent),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.phone ,color: Colors.blue),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(" +3307605543  ",
                      style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
                SizedBox(height: 10),
                Icon(Icons.calendar_month, color: Colors.transparent),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
