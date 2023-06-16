import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kine/ClassAll/Appointment.dart';
import 'package:kine/ClassAll/TimeSlot.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../ClassAll/Conversation.dart';
import '../ClassAll/Messages.dart';
import '../ClassAll/Note.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import '../LocalDatabase/RoleProvider.dart';
import 'authservice.dart';

class WebSocketProvider extends ChangeNotifier {
  //late final IOWebSocketChannel channel;
  IOWebSocketChannel? channel;
  List<Messages> messages = [];
  late final DatabaseProvider databaseProvider;


  bool _isConnected = false;

  bool get isConnected => _isConnected;



  WebSocketProvider() {
    print("establish ws");
    // Access the role using roleProvider.role

    // Connect to the WebSocket server and start listening for messages
    _initializeWebSocketConnection();
  }

  Future<void> _initializeWebSocketConnection() async {
    databaseProvider = DatabaseProvider();
    await databaseProvider.open();
    await establishWebSocketConnection();
  }


  Future<void> establishWebSocketConnection() async {
    // Establish the WebSocket connection
    // ...



    String myid = 'ok';

    print('establish web socket la');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await AuthService().getInfoUser(prefs.getString('token'));

    if (response != null) {
      final responseData = json.decode(response.toString());
      myid = responseData['id'];
      //print("mon id dans auth" + responseData['id']);
    }

    await Firebase.initializeApp();

    FirebaseMessaging.instance.getToken().then((fcmtoken){

      print("getToken dans websocket : $fcmtoken");
      AuthService().isFcmtokenSame(fcmtoken!, myid, prefs.getString('role'));
    });

    final headers = {
      'Authorization': 'Bearer ${prefs.getString('token')}',
      'userId': myid,
    };

    // Initialize the 'channel' field
    // Connect to the WebSocket server
    channel = IOWebSocketChannel.connect(
        Uri.parse('wss://10.0.2.2:3000'),
        headers: headers
    ); // Connect to the WebSocket server);


    // Listen for incoming messages
    channel?.stream.listen((newMessage) async {
      try {
        final data = jsonDecode(newMessage);

        // si le message envoyé est une demande de message direct
        if (data['type'] == "incomingmessage") {
          final type = data['type'];
          final recipient = data['recipient'];
          final sender = data['sender'];
          final content = data['content'];
          final sendername = data['sendername'];

          print('Type: $type');
          print('sendername: $sendername');
          print('sender: $sender');
          print('recipient: $recipient');
          print('Server response: $content');
          // Handle the received message as needed

          bool testIfExist = false;
          try {
            testIfExist =
            await databaseProvider.isConversationExists(recipient, sender);
            print('booooooool : $testIfExist');
          } catch (error) {
            print('Error bool: $error');
          }


          // si la conversation existe deja, on ajoute seulement le message
          // en prenant l'id de la conversation
          if (testIfExist) {
            int? idConv = await databaseProvider.getConversationId(
                recipient, sender);
            if (idConv != null) {
              print("Conversation ID: $idConv");
            } else {
              print("Conversation not found.");
            }

            if (idConv != null) {
              final message = Messages(
                conversationId: idConv,
                senderId: sender,
                content: content,
                sentTime: DateTime.now(),
              );

              await databaseProvider.insertMessage(message);
              // Add the message to the list
              messages.add(message);
              notifyListeners();
            } else {
              print("id null");
            }

            // du coup la si la conversation n'est pas creer, on la creer
            // et on ajoute le message
          } else {
            print("conversation n'existe pas , alors on l'as crée");
            final conversation = Conversation(
              userId: recipient,
              name: sendername,
              otherUserId: sender,
              lastMessage: content,
              lastMessageTime: DateTime.now(),
            );

            //print("id conv" + conversation.id.toString());
            await databaseProvider.insertConversation(conversation);

            int? idConv = await databaseProvider.getConversationId(
                recipient, sender);
            if (idConv != null) {
              print("Conversation ID: $idConv");
            } else {
              print("Conversation not found.");
            }


            final message = Messages(
              conversationId: idConv!,
              senderId: sender,
              content: content,
              sentTime: DateTime.now(),
            );

            await databaseProvider.insertMessage(message);
            messages.add(message);
            notifyListeners();
          }


          // rendez vous du patient vers le kine
        } else if (data['type'] == "rdvincomingkine") {
          final type = data['type'];
          final recipient = data['idkine'];
          final sender = data['idpatient'];
          final starthour = data['starthour'];
          final endhour = data['endhour'];
          final year = data['year'];
          final month = data['month'];
          final day = data['day'];
          final motif = data['motif'];
          final category = data['category'];
          final sendername = data['sendername'];

          print('Type: $type');
          print('sendername: $sendername');
          print('sender: $sender');
          print('recipient: $recipient');
          print('Server response: $starthour');
          print('category: $category');
          print('motif: $motif');


          //print("on start" + start.toString());


          DateTime datet = DateTime(year, month, day);

          try {
            final appointment = Appointment(
                title: motif,
                dateTime: datet,
                idkine: recipient,
                starthour: starthour,
                endhour: endhour,
                idpatient: sender,
                category: category,
                status: 'ok',
                sender: 'patient',
                motif: motif
            );

            //print("id conv" + conversation.id.toString());
            await databaseProvider.insertRdv(appointment);
          } catch (e) {
            print(e);
          }


          // rendez vous du kine vers le patient
        } else if (data['type'] == "rdvincomingpatient") {
          final type = data['type'];
          final recipient = data['idpatient'];
          final sender = data['idkine'];
          final starthour = data['starthour'];
          final endhour = data['endhour'];
          final year = data['year'];
          final month = data['month'];
          final day = data['day'];
          final category = data['category'];
          final motif = data['motif'];
          final sendername = data['sendername'];

          print('Type: $type');
          print('sendername: $sendername');
          print('sender: $sender');
          print('recipient: $recipient');

          DateTime datet = DateTime(year, month, day);

          final appointment = Appointment(
              title: motif,
              dateTime: datet,
              idkine: sender,
              starthour: starthour,
              endhour: endhour,
              idpatient: recipient,
              category: category,
              status: 'request',
              sender: 'kine',
              motif: motif
          );

          //print("id conv" + conversation.id.toString());
          await databaseProvider.insertRdv(appointment);


        } else if (data['type'] == "deplacerrdvpatient") {
          final type = data['type'];
          final recipient = data['idpatient'];
          final sender = data['idkine'];
          final starthour = data['starthour'];
          final endhour = data['endhour'];
          final year = data['year'];
          final month = data['month'];
          final day = data['day'];

          final oldstarthour = data['oldstarthour'];
          final oldendhour = data['oldendhour'];
          final oldyear = data['oldyear'];
          final oldmonth = data['oldmonth'];
          final oldday = data['oldday'];

          print('Type: $type');
          print('sender: $sender');
          print('recipient: $recipient');

          DateTime olddatetime = DateTime(oldyear, oldmonth, oldday);

          try{
            Appointment? app =  await databaseProvider.getOneRdv(olddatetime, oldstarthour, oldendhour);

            if (app != null) {
              DateTime datet = DateTime(year, month, day);
              final updatedAppointment = app.copyWith(
                dateTime: datet,
                starthour: starthour,
                endhour: endhour,
              );

              await databaseProvider.updateAppointment(updatedAppointment);

            } else {
              print("ok null value donc next");
              // Handle the case when the appointment is null
            }

          } catch(e){
            print(e);
          }

        }else if (data['type'] == "acceptrdv") {
          try{
            final starthour = data['starthour'];
            final endhour = data['endhour'];
            final year = data['year'];
            final month = data['month'];
            final day = data['day'];
            final sender = data['idkine'];


            print('starthour: $starthour');
            print('endhour: $endhour');
            print('year: $year');
            print('month: $month');

            DateTime t = DateTime(year, month, day);
            Appointment? app =  await databaseProvider.getOneRdv(t, starthour, endhour);
            app?.status = "ok";
            print("app : " + app!.toString());

            if (app != null) {
              await databaseProvider.updateAppointment(app);
            } else {
              print("ok null value donc next");
              // Handle the case when the appointment is null
            }
          }catch(e){
            print(e);
          }

        } else if (data['type'] == "envoienote") {


          try{
            final note = data['note'];
            final recipient = data['idpatient'];
            final year = data['year'];
            final month = data['month'];
            final day = data['day'];

            print('note: $note');
            print('recipient: $recipient');
            print('year: $year');
            print('month: $month');

            DateTime t = DateTime(year, month, day);

            final noteadd = Note(
              patientid: recipient,
              note: note,
              dateTime: t,
            );

            await databaseProvider.insertNote(noteadd);


          }catch(e){
            print(e);
          }

        }

        // Notify listeners about the message update
      } catch (error) {
        print('Error parsing message: $error');
      }
    },
      onError: (error) {
        print('WebSocket error: $error');
        // Handle WebSocket errors
      },
      onDone: () {
        print('WebSocket connection closed');
        // Handle WebSocket connection closed
      },
    );
  }

  TimeOfDay parseToTimeOfDay(String timeslot) {
    List<String> timeParts = timeslot.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    TimeOfDay start = TimeOfDay(hour: hour, minute: minute);

    return start;
  }

  Future<String> getNameByToken(String? token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var response = await AuthService().getInfoUser(prefs.getString('token'));

    if (response != null) {
      final responseData = json.decode(response.toString());
      return responseData['id'];
      //print("mon id dans auth" + responseData['id']);
    }

    return 'ok';
  }

  Future<String> getToken() async {
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    messaging.getToken().then((value){
      print("getToken in socket function: $value");
      return value;
    });

    return "non";
  }


  Future<void> sendMessage(String token,String recipientId, String content) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();


    String fcmtoken = await AuthService().getFcmtokenById(recipientId, prefs.getString('role'));
    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    final message = {
      'type': 'messagesend',
      'recipient': recipientId,
      'token': token,
      'content': content,
      'fcmtoken': fcmtoken
    };
    channel?.sink.add(jsonEncode(message));

  }


  // un patient qui envoit un rdv au kine
  Future<void> sendRdvToKine(DateTime date, TimeSlot hour, String category, String? token, motif) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    String fcmtoken = await AuthService().getFcmtokenById('64689aed8ce36c551c10eae1', prefs.getString('role'));


    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    print('envoie du websocket rdv vers serveur avec motif : ' + motif);

    var day = date.day;
    var month = date.month;
    var year = date.year;
    var start = '${hour.startHour.hour}:${hour.startHour.minute.toString().padLeft(2, '0')}';
    var end = '${hour.endHour.hour}:${hour.endHour.minute.toString().padLeft(2, '0')}';

    final rdv = {
      'type': 'demanderdvkine',
      'day': day,
      'month': month,
      'year': year,
      'starthour': start,
      'endhour': end,
      'category': category,
      'motif': motif,
      'tokenpatient': token,
      'recipient': '64689aed8ce36c551c10eae1',
      'fcmtoken': fcmtoken
    };
    channel?.sink.add(jsonEncode(rdv));

    await AuthService().addRdv(date, start, end);
    String recipient = await getNameByToken(token);

    final appointment = Appointment(
        title: motif,
        dateTime: date,
        idkine: '64689aed8ce36c551c10eae1',
        starthour: start,
        endhour: end,
        idpatient: recipient,
        category: category,
        status: 'ok',
        sender: 'kine',
        motif: motif,

    );

    //print("id conv" + conversation.id.toString());
    await databaseProvider.insertRdv(appointment);

  }

  // un kine qui envoit un rdv au patient
  Future<void> sendRdvToPatient(DateTime date, TimeSlot hour, String category, String? token, motif, idpatient) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String fcmtoken = await AuthService().getFcmtokenById(idpatient, prefs.getString('role'));


    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    print('envoie du websocket rdv vers serveur');

    var day = date.day;
    var month = date.month;
    var year = date.year;
    var start = '${hour.startHour.hour}:${hour.startHour.minute.toString().padLeft(2, '0')}';
    var end = '${hour.endHour.hour}:${hour.endHour.minute.toString().padLeft(2, '0')}';

    final rdv = {
      'type': 'demanderdvpatient',
      'day': day,
      'month': month,
      'year': year,
      'starthour': start,
      'endhour': end,
      'category': category,
      'motif': motif,
      'idpatient': idpatient,
      'tokenkine': token,
      'fcmtoken': fcmtoken
    };
    channel?.sink.add(jsonEncode(rdv));

    String recipient = await getNameByToken(token);

    final appointment = Appointment(
        title: motif,
        dateTime: date,
        idkine: '64689aed8ce36c551c10eae1',
        starthour: start,
        endhour: end,
        idpatient: idpatient,
        category: category,
        status: 'waitforpatient',
        sender: 'kine',
        motif: motif
    );

    //print("id conv" + conversation.id.toString());
    await databaseProvider.insertRdv(appointment);

  }


  // un patient qui accepte le rdv du kine
  Future<void> acceptRdvToKine(DateTime date, TimeSlot hour,  String? token, motif, category, idpatient) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String fcmtoken = await AuthService().getFcmtokenById('64689aed8ce36c551c10eae1', prefs.getString('role'));


    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    print('envoie du websocket rdv vers serveur pour accept rdv to kine');

    var day = date.day;
    var month = date.month;
    var year = date.year;
    var start = '${hour.startHour.hour}:${hour.startHour.minute.toString().padLeft(2, '0')}';
    var end = '${hour.endHour.hour}:${hour.endHour.minute.toString().padLeft(2, '0')}';

    final rdv = {
      'type': 'acceptrdvkine',
      'day': day,
      'month': month,
      'year': year,
      'starthour': start,
      'endhour': end,
      'tokenpatient': token,
      'recipient': '64689aed8ce36c551c10eae1',
      'fcmtoken': fcmtoken

    };
    channel?.sink.add(jsonEncode(rdv));

    await AuthService().addRdv(date, start, end);



    final appointment = Appointment(
        title: motif,
        dateTime: date,
        idkine: '64689aed8ce36c551c10eae1',
        starthour: start,
        endhour: end,
        idpatient: idpatient,
        category: category,
        status: 'ok',
        sender: 'kine',
        motif: motif
    );

    //print("id conv" + conversation.id.toString());
    await databaseProvider.insertRdv(appointment);

  }


  // un patient qui accepte le rdv du kine



  Future<void> kineDeplaceRdv(Appointment oldapp, DateTime date, TimeSlot hour,  String? token, idpatient) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String fcmtoken = await AuthService().getFcmtokenById(idpatient, prefs.getString('role'));


    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    print('envoie du websocket rdv vers serveur pour deplacer rdv');

    var oldday = oldapp.dateTime.day;
    var oldmonth = oldapp.dateTime.month;
    var oldyear = oldapp.dateTime.year;
    var oldstarthour = oldapp.starthour;
    var oldendhour = oldapp.endhour;


    var day = date.day;
    var month = date.month;
    var year = date.year;
    var start = '${hour.startHour.hour}:${hour.startHour.minute.toString().padLeft(2, '0')}';
    var end = '${hour.endHour.hour}:${hour.endHour.minute.toString().padLeft(2, '0')}';

    final rdv = {
      'type': 'deplacerrdv',
      'oldday': oldday,
      'oldmonth': oldmonth,
      'oldyear': oldyear,
      'oldstarthour': oldstarthour,
      'oldendhour': oldendhour,
      'newday': day,
      'newmonth': month,
      'newyear': year,
      'newstarthour': start,
      'newendhour': end,
      'tokenkine': token,
      'recipient': idpatient,
      'fcmtoken': fcmtoken
    };
    channel?.sink.add(jsonEncode(rdv));

  }


  Future<void> envoieNoteToPatient(DateTime date, int note, idpatient, String? token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String fcmtoken = await AuthService().getFcmtokenById(idpatient, prefs.getString('role'));


    if (channel == null ) {
      print('WebSocket channel is not available');
      // Handle the scenario when the WebSocket channel is not available
      return;
    }

    print('envoie du websocket rdv vers serveur pour deplacer rdv');

    var day = date.day;
    var month = date.month;
    var year = date.year;

    final rdv = {
      'type': 'envoienote',
      'note': note,
      'day': day,
      'month': month,
      'year': year,
      'recipient': idpatient,
      'tokenkine': token,
      'fcmtoken': fcmtoken
    };
    channel?.sink.add(jsonEncode(rdv));

  }




}
