import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
          body: Column(
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
                        "nom",
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
                        initialValue: 'nom',
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
                        initialValue: 'mail',
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
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


                          },
                          child: const Text('modifier'),
                        ),
                      )
                    ]),
                  )),
            ],
          )),
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
