import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kine/Profile/Graphique.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../ClassAll/Note.dart';
import '../LocalDatabase/DatabaseProvider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _database; // Change the type to nullable Database

  DatabaseHelper.internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'test.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }


  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE test (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        note INTEGER,
        patient TEXT,
        date TEXT
        
      )
    ''');
  }

  Future<void> deleteAllNotes() async {
    Database db = await database;
    await db.delete('test');
  }
  Future<int> insertSeance(int note, String date, String patient) async {
    Database db = await database;
    Map<String, dynamic> row = {
      'note': note,
      'patient': patient,
      'date': date,
    };
    print("insertion faite !!!");
    return await db.insert('test', row);
  }

  Future<List<Map<String, dynamic>>> getSeances() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    await databaseHelper.initDatabase(); // Initialise la base de données
    Database db = await databaseHelper.database;
    return await db.query('test');
  }

  Future<List<Map<String, dynamic>>> afficherSeances() async {
    List<Map<String, dynamic>> seances = await getSeances();

    for (var seance in seances) {
      int note = seance['note'];
      String date = seance['date'];

      print('Note: $note, Date: $date');
    }
    return seances;
  }
}

class RootApp extends StatefulWidget {
  final Map<String, dynamic> user;

  const RootApp({Key? key, required this.user}) : super(key: key);

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool showDial = false;
  late final DatabaseProvider databaseProvider;

  @override
  void initState()  {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage:");
      print("onMessage: $message");
      final snackBar =
      SnackBar(content: Text(message.notification?.title ?? ""));
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
    },
    );
    super.initState();
    databaseProvider = DatabaseProvider();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await databaseProvider.open();
  }

  void showAlerte(BuildContext context, String id) {
    String eventName = "";
    String patientFirstName = "";
    DateTime startDate = DateTime.now();
    DateTime startTime = DateTime.now();
    var rating;
    print("l 'id du patient est " + id);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajout d'un nouveau rendez-vous"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 10),
                    Text('Note (entre 0 et 10):'),
                  ],
                ),
                SizedBox(height: 5),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    // Mettre à jour la variable de note avec la valeur entrée
                    setState(() {
                      rating = value;
                    });
                  },
                  validator: (value) {
                    if (value != "") {
                      return 'Veuillez entrer une note.';
                    }
                    rating = int.tryParse(value!);
                    if (rating == null || rating < 0 || rating > 10) {
                      return 'Veuillez entrer une note valide entre 0 et 10.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 10),
                    Text('Jour de la séance:'),
                  ],
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        startDate = selectedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(startDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {

                DatabaseHelper db = DatabaseHelper();
                db.deleteAllNotes();
                print("supprimé");
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Insérer l'objet Appointment dans la base de données



                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Récapitulatif'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Rendez vous avec  '$eventName' '$patientFirstName'"),
                          Text(
                              "Date du rendez-vous : ${DateFormat('yyyy-MM-dd').format(startDate)}"),
                          Text("Note de la séance: ${rating}"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            DatabaseHelper databaseHelper = DatabaseHelper();
                            int test = int.tryParse(rating)!;
                            await databaseHelper.insertSeance(test,
                                DateFormat('yyyy-MM-dd').format(startDate), id);

                            final noteadd = Note(
                              patientid: widget.user['id'],
                              note: test,
                              dateTime: startDate,
                            );

                            await databaseProvider.insertNote(noteadd);
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    ).then((value) {
      setState(() {
        showDial = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("PROFILE"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_rounded),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // COLUMN THAT WILL CONTAIN THE PROFILE
          Column(
            children:  [
              CircleAvatar(
                  radius: 50, backgroundImage: AssetImage("assets/icon.png")),
              SizedBox(height: 10),
              Text(
                user['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("12/07/2001")
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 180,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final card = profileCompletionCards[index];
                return SizedBox(
                  width: 160,
                  child: Card(
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Icon(
                            card.icon,
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            card.title,
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              print(showDial);

                              if (card.title ==
                                  "Noter l'évolution du patient") {
                                print("je suis ici");
                                setState(() {
                                  showDial = true;
                                });
                                showAlerte(context, "52");

                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(card.buttonText),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) =>
              const Padding(padding: EdgeInsets.only(right: 5)),
              itemCount: profileCompletionCards.length,
            ),
          ),
          const SizedBox(height: 35),
          ...List.generate(
            customListTiles.length,
                (index) {
              final tile = customListTiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  child: ListTile(
                      leading: Icon(tile.icon),
                      title: Text(tile.title),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle the onTap action for each CustomListTile
                        // You can access the tile properties (icon, title, etc.) here
                        // Add your code here
                        if (tile.title == "Evolution") {
                          print("Clicked on Evolution tile!");
                          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notes()));
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Notes(user: widget.user))
                          );

                        } else {
                          print("Clicked on a different tile!");
                        }
                      }),
                ),
              );
            },
          )
        ],
      ),
      //bottomNavigationBar: BottomBar(),
    );
  }
}

class ProfileCompletionCard {
  final String title;
  final String buttonText;
  final IconData icon;

  ProfileCompletionCard({
    required this.title,
    required this.buttonText,
    required this.icon,
  });
}

List<ProfileCompletionCard> profileCompletionCards = [
  ProfileCompletionCard(
    title: "Noter l'évolution du patient",
    icon: CupertinoIcons.square_list,
    buttonText: "Ajouter",
  ),
  ProfileCompletionCard(
    title: "Deposer un document",
    icon: CupertinoIcons.doc,
    buttonText: "Upload",
  ),
  ProfileCompletionCard(
    title: "Add your skills",
    icon: CupertinoIcons.square_list,
    buttonText: "Add",
  ),
];

class CustomListTile {
  final IconData icon;
  final String title;

  CustomListTile({
    required this.icon,
    required this.title,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: Icons.insights,
    title: "Evolution",
  ),
  CustomListTile(
    icon: Icons.location_on_outlined,
    title: "Location",
  ),
];