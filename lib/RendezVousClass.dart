import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'kine_database.db');
    return await openDatabase(databasePath, version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE IF NOT EXISTS appointments ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'nom TEXT, '
          'prenom TEXT, '
          'start_date TEXT, '
          'start_time TEXT'
          ')');
    });
  }

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<void> deleteAllAppointments() async {
    final db = await instance.database;
    await db.delete('appointments');
  }

  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appointments');

    return List.generate(maps.length, (index) {
      return Appointment(
        nom: maps[index]['nom'],
        prenom: maps[index]['prenom'],
        startDate: DateTime.parse(maps[index]['start_date']),
        startTime: DateTime.parse(maps[index]['start_time']),
      );
    });
  }
}



class Appointment {
  String prenom;
  String nom;
  DateTime startDate;
  DateTime startTime;

  Appointment({
    required this.prenom,
    required this.nom,
    required this.startDate,
    required this.startTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom':nom,
      'prenom': prenom,
      'start_date': startDate.toIso8601String(),
      'start_time': startTime.toIso8601String(),
    };
  }
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      nom: map['nom'],
      prenom: map['prenom'],
      startDate: DateTime.parse(map['start_date']),
      startTime: DateTime.parse(map['start_time']),
    );
  }
}