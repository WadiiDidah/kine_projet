import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Introduction.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}
class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return MaterialApp(home: Introduction());
  }

}
