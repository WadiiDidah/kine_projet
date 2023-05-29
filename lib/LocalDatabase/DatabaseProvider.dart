import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../ClassAll/Conversation.dart';
import '../ClassAll/Messages.dart';

class DatabaseProvider {
  static const String dbName = 'conversations.db';
  static const String conversationTable = 'conversations';
  static const String messageTable = 'messages';

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
    });
  }

  Future<bool> isConversationExists(String userId, String otherUserId) async {


    final List<Map<String, dynamic>> result = await db!.query(
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

  void removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
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
