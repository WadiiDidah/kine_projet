import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Introduction.dart';
import 'LocalDatabase/DatabaseProvider.dart';
import 'LocalDatabase/RoleProvider.dart';
import 'api/MyApplicationObserver.dart';
import 'api/WebSocketProvider.dart';

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
