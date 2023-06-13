import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kine/api/authservice.dart';
import 'package:kine/homePatient.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Introduction.dart';
import 'LocalDatabase/DatabaseProvider.dart';
import 'LocalDatabase/RoleProvider.dart';
import 'RDV/AppointmentsKinePage.dart';
import 'api/MyApplicationObserver.dart';
import 'api/WebSocketProvider.dart';
import 'homeKine.dart';

Future<void> main() async {

  // Override the HttpOverrides class to disable certificate verification
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if(await DatabaseProvider().hasToken()){
  print("le token existe encore ptn");
  } else {
  print(" pas de token au debut de l'app");
  };

  // Enregistrer la méthode onExit pour la fermeture de l'application
  WidgetsBinding.instance.addObserver(MyApplicationObserver());

  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.getToken().then((value){
    print("getToken : $value");
  });

  NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false,
  sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // application in background but still alive
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("onMessageOpenedApp $message");
    //Navigator.push(context, MaterialPageRoute(builder: (context) =>  AppointmentsKinePage()));
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: $message');

    if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider<RoleProvider>(
        create: (_) => RoleProvider(),
      ),
      ChangeNotifierProvider<WebSocketProvider>(
        create: (_) => WebSocketProvider(),
      ),
    ],
    child: MyApp(),
  ),
  );


}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient httpClient = super.createHttpClient(context);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return httpClient;
  }
}



class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    //final webSocketProvider = Provider.of<WebSocketProvider>(context);
    //final messages = webSocketProvider.messages;

    return MaterialApp(home: Introduction());
  }

}

// Firebase Messaging background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message}');
  // Handle the background message here
}



/**
Future<void> main() async {


  // Override the HttpOverrides class to disable certificate verification
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if(await DatabaseProvider().hasToken()){
    print("le token existe encore ptn");
  } else {
    print(" pas de token au debut de l'app");
  };

  // Enregistrer la méthode onExit pour la fermeture de l'application
  WidgetsBinding.instance.addObserver(MyApplicationObserver());

  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  messaging.getToken().then((value){
    print("getToken : $value");
  });

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');


  // application in background but still alive
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("onMessageOpenedApp $message");
    //Navigator.push(context, MaterialPageRoute(builder: (context) =>  AppointmentsKinePage()));
  });


  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message){


  });




  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider<RoleProvider>(
        create: (_) => RoleProvider(),
      ),
      ChangeNotifierProvider<WebSocketProvider>(
        create: (_) => WebSocketProvider(),
      ),
    ],
    child: MyApp(),

  ),

  );


}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient httpClient = super.createHttpClient(context);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return httpClient;
  }
}



class MyApp extends StatelessWidget {

  Future<String?> _getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "",
      home: FutureBuilder<bool>(
        future: DatabaseProvider().hasToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Scaffold(body: Text('Error: ${snapshot.error}'));
          } else {
            bool hasToken = snapshot.data ?? false;
            if (hasToken) {
              return FutureBuilder<String?>(
                future: _getRole(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(body: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Scaffold(body: Text('Error: ${snapshot.error}'));
                  } else {
                    String? role = snapshot.data;
                    if (role == 'kine') {
                      return const MaterialApp(home: HomeKine(role: 'kine'));

                    } else {
                      // Replace `HomeUser` with the desired home page for users
                      return const MaterialApp(home: HomePatient(role: 'user'));
                      return MaterialApp(home: Introduction());

                    }
                  }
                },
              );
            } else {
              print("Pas de token");
              return MaterialApp(home: Introduction());
            }
          }
        },
      ),
    );
  }

}


// Firebase Messaging background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message}');
  // Handle the background message here
}
    **/