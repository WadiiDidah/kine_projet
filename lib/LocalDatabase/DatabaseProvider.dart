import 'package:kine/ClassAll/Appointment.dart';
import 'package:kine/ClassAll/Note.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../ClassAll/Conversation.dart';
import '../ClassAll/Messages.dart';

class DatabaseProvider {
  static const String dbName = 'conversations.db';
  static const String conversationTable = 'conversations';
  static const String messageTable = 'messages';
  static const String rdvTable = 'rdv';
  static const String noteTable = 'note';

  late Database db;

  Future<void> open() async {

    //addSampleData();
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
      CREATE TABLE $conversationTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,   
        name TEXT,     
        userId TEXT,
        otherUserId TEXT,
        lastMessage TEXT,
        lastMessageTime TEXT
      )
      ''');

      await db.execute('''
      CREATE TABLE $messageTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversationId INTEGER,
        senderId TEXT,
        content TEXT,
        sentTime TEXT
      )
      ''');

      await db.execute('''
      CREATE TABLE $rdvTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        motif TEXT,
        category TEXT,
        dateTime TEXT,
        starthour TEXT,
        endhour TEXT,
        idkine TEXT,
        idpatient TEXT,
        status TEXT,
        sender TEXT
      )
      ''');

      await db.execute('''
      CREATE TABLE $noteTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientid TEXT,
        note INTEGER,
        dateTime TEXT
      )
      ''');

    });
  }

  Future<bool> isConversationExists(String userId, String otherUserId) async {


    final List<Map<String, dynamic>> result = await db.query(
      conversationTable,
      where: 'userId = ? AND otherUserId = ?',
      whereArgs: [userId, otherUserId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<int?> getConversationId(String userId, String otherUserId) async {
    if (db == null) {
      // Handle the case when the database is not initialized
      return null;
    }

    final List<Map<String, dynamic>> result = await db.query(
      conversationTable,
      columns: ['id'],
      where: 'userId = ? AND otherUserId = ?',
      whereArgs: [userId, otherUserId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result[0]['id'] as int?;
    } else {
      return null;
    }
  }


  Future<void> insertConversation(Conversation conversation) async {
    print("insertion en bdd de la conv");
    await db.insert(conversationTable, conversation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Conversation>> getAllConversations() async {
    final List<Map<String, dynamic>> maps = await db.query(conversationTable);
    return List.generate(maps.length, (i) {
      return Conversation(
        id: maps[i]['id'],
        name: maps[i]['name'],
        userId: maps[i]['userId'],
        otherUserId: maps[i]['otherUserId'],
        lastMessage: maps[i]['lastMessage'],
        lastMessageTime: DateTime.parse(maps[i]['lastMessageTime']),

      );
    });
  }

  Future<void> insertMessage(Messages message) async {
    print("insertion en bdd du message");

    await db.insert(messageTable, message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  Future<void> deleteMessage(int id) async {
    print("deleting message from the database");

    await db.delete(
      messageTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertNote(Note note) async {
    print("insertion en bdd du rendez vous appointment");

    await db.insert(noteTable, note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }


  Future<void> insertRdv(Appointment appointment) async {
    print("insertion en bdd du rendez vous appointment");

    await db.insert(rdvTable, appointment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    print("Deleting appointment from the database");

    await db.delete(
      rdvTable,
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<void> updateAppointment(Appointment updatedAppointment) async {

    print("update en bdd sqflite");

    await db.update(
      rdvTable,
      updatedAppointment.toMap(),
      where: 'id = ?',
      whereArgs: [updatedAppointment.id],
    );
  }




  Future<List<Appointment>> getAllRdvSortByIdAndSender(String userId, String sender) async {
    final List<Map<String, dynamic>> maps = await db.query(
      rdvTable,
      where: 'sender = ? AND (idpatient = ? OR idkine = ?)',
      whereArgs: [sender, userId, userId]
    );
    return List.generate(maps.length, (i) {
      return Appointment(
        id: maps[i]['id'],
        motif: maps[i]['motif'],
        title: maps[i]['title'],
        starthour: maps[i]['starthour'],
        endhour: maps[i]['endhour'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        idkine: maps[i]['idkine'],
        idpatient: maps[i]['idpatient'],
        status: maps[i]['status'],
        sender: maps[i]['sender'],
        category: maps[i]['category'],
      );
    });
  }

  Future<void> updateAppointmentStatus(Appointment appointment, String newStatus) async {
    // Convertir la date et l'heure en format texte pour la base de données
    String formattedDateTime = appointment.dateTime.toIso8601String();

    // Mettre à jour l'enregistrement correspondant dans la base de données
    await db.update(
      rdvTable,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }


  Future<List<Appointment>> getAllRdv() async {
    final List<Map<String, dynamic>> maps = await db.query(
        rdvTable,
    );
    return List.generate(maps.length, (i) {
      return Appointment(
        id: maps[i]['id'],
        motif: maps[i]['motif'],
        title: maps[i]['title'],
        starthour: maps[i]['starthour'],
        endhour: maps[i]['endhour'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        idkine: maps[i]['idkine'],
        idpatient: maps[i]['idpatient'],
        status: maps[i]['status'],
        sender: maps[i]['sender'],
        category: maps[i]['category'],
      );
    });
  }

  Future<Appointment?> getMostRecentRdvForPatient() async {
    final List<Map<String, dynamic>> maps = await db.query(
      rdvTable,
      orderBy: 'dateTime DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      // No appointment found
      return null;
    }

    final appointmentMap = maps.first;
    return Appointment(
      id: appointmentMap['id'],
      motif: appointmentMap['motif'],
      title: appointmentMap['title'],
      starthour: appointmentMap['starthour'],
      endhour: appointmentMap['endhour'],
      dateTime: DateTime.parse(appointmentMap['dateTime']),
      idkine: appointmentMap['idkine'],
      idpatient: appointmentMap['idpatient'],
      status: appointmentMap['status'],
      sender: appointmentMap['sender'],
      category: appointmentMap['category'],
    );
  }

  Future<List<Appointment>> getRdvForPatient(int userId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      rdvTable,
      where: 'idpatient = ?',
      whereArgs: [userId],
      orderBy: 'sentTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Appointment(
        id: maps[i]['id'],
        motif: maps[i]['motif'],
        title: maps[i]['title'],
        starthour: maps[i]['starthour'],
        endhour: maps[i]['endhour'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        idkine: maps[i]['idkine'],
        idpatient: maps[i]['idpatient'],
        status: maps[i]['status'],
        sender: maps[i]['sender'],
        category: maps[i]['category'],
      );
    });
  }


  Future<List<Note>> getAllNote(String userId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      noteTable,
      where: 'patientid = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        dateTime: DateTime.parse(maps[i]['dateTime']),
        patientid: maps[i]['patientid'],
        note: maps[i]['note'],
      );
    });
  }

  Future<Appointment?> getOneRdv(DateTime d, String starthour, String endhour) async {
    try{
      print("dans getonerdv");

      print(starthour);
      print(endhour);
      final String formattedDateTime = d.toIso8601String();

      print(formattedDateTime);
      final List<Map<String, dynamic>> maps = await db.query(
        rdvTable,
        where: 'dateTime = ? AND starthour = ? AND endhour = ?',
        whereArgs: [formattedDateTime, starthour, endhour],
        limit: 1, // Limit the result to one appointment
      );

      if (maps.isNotEmpty) {
        print("map not empty");
        Map<String, dynamic> map = maps.first;
        return Appointment(
          id: map['id'],
          motif: map['motif'],
          title: map['title'],
          starthour: map['starthour'],
          endhour: map['endhour'],
          dateTime: DateTime.parse(map['dateTime']),
          idkine: map['idkine'],
          idpatient: map['idpatient'],
          status: map['status'],
          sender: map['sender'],
          category: map['category'],
        );
      }
     return null;
    }catch(e){
      print("ok" + e.toString());
    }

  }


  Future<List<Messages>> getMessagesForConversation(int conversationId) async {
    final List<Map<String, dynamic>> maps = await db.query(
      messageTable,
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'sentTime ASC',
    );
    return List.generate(maps.length, (i) {
      return Messages(
        id: maps[i]['id'],
        conversationId: maps[i]['conversationId'],
        senderId: maps[i]['senderId'],
        content: maps[i]['content'],
        sentTime: DateTime.parse(maps[i]['sentTime']),
      );
    });
  }



  void addSampleData() async {
    //await databaseProvider.open();

    // Sample conversations
    final conversation1 = Conversation(
      id: 1,
      userId: 'user1',
      name: 'USER1',
      otherUserId: 'user2',
      lastMessage: 'Hello',
      lastMessageTime: DateTime.now(),
    );

    final conversation2 = Conversation(
      id: 2,
      userId: 'user1',
      name: 'USER2',
      otherUserId: 'user3',
      lastMessage: 'How are you?',
      lastMessageTime: DateTime.now(),
    );

    // Insert conversations into the database
    await insertConversation(conversation1);
    await insertConversation(conversation2);

    // Sample messages
    final message1 = Messages(
      id: 1,
      conversationId: 1,
      senderId: 'user1',
      content: 'Bo goss mon pote ?',
      sentTime: DateTime.now(),
    );

    final message2 = Messages(
      id: 2,
      conversationId: 1,
      senderId: 'user3',
      content: 'Khalass bien fort frr',
      sentTime: DateTime.now(),
    );

    // Insert messages into the database
    await insertMessage(message1);
    await insertMessage(message2);
  }


  // Storing the token
  void storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  void storeRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('role', role);
  }

  void removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }

  void removeRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('role');
  }

  void removeAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<bool> hasToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }



}
