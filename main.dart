import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String nom = '';
  String email = '';
  String numero = '';
  String name = '';
  String mail = '';
  String num = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Profil"),
        ),
        body: FutureBuilder<List<Profil>>(
            future: DatabaseHelper.instance.getProfil(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Profil>> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: Text('Loading...'));
              }
              print(snapshot);
              snapshot.data!.map((profil) {
                name = profil.nom;
                mail = profil.mail;
                num = profil.numero;
                print(name);
              });
              return Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.all(20),
                            child: const Icon(
                              Icons.face_3_rounded,
                              size: 30,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            "pedro",
                            style: const TextStyle(fontSize: 25),
                          )
                        ],
                      )),
                  Container(
                      child: Form(
                    key: _formKey,
                    child: Column(children: [
                      Text("Nom"),
                      TextFormField(
                        initialValue: 'pedro',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            nom = value;
                          });
                        },
                      ),
                      Text("numero"),
                      TextFormField(
                        initialValue: '04 52 12 12 13',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            numero = value;
                          });
                        },
                      ),
                      Text("mail"),
                      TextFormField(
                        initialValue: 'pedromodu13@outlook.com',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (value == 'pedromodu13@outlook.com') return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validate will return true if the form is valid, or false if
                            // the form is invalid.
                            if (_formKey.currentState!.validate()) {
                              // Process data.
                            }

                            await DatabaseHelper.instance.add(
                              Profil(nom: nom, mail: email, numero: numero),
                            );
                          },
                          child: const Text('modifier'),
                        ),
                      )
                    ]),
                  )),
                ],
              );
            }),
      ),
    );
  }
}

class Profil {
  final int? id;
  final String nom;
  final String mail;
  final String numero;

  Profil(
      {this.id, required this.nom, required this.mail, required this.numero});

  factory Profil.fromMap(Map<String, dynamic> json) => new Profil(
      id: json['id'],
      nom: json['nom'],
      mail: json['mail'],
      numero: json['numero']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'mail': mail,
      'numero': numero,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'profil.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profil(
          id INTEGER PRIMARY KEY,
          nom TEXT,
          mail TEXT,
          numero TEXT
      )
      ''');
    await db.insert(
        'profil',
        Profil(nom: "pedro", mail: "pedromorais@outlook.com", numero: "0785212")
            as Map<String, Object?>);
  }

  Future<List<Profil>> getProfil() async {
    Database db = await instance.database;
    var profils = await db.query('profil', orderBy: 'nom');
    List<Profil> profilList = profils.isNotEmpty
        ? profils.map((c) => Profil.fromMap(c)).toList()
        : [];
    return profilList;
  }

  Future<int> add(Profil profil) async {
    Database db = await instance.database;
    return await db.insert('profil', profil.toMap());
  }
}
