import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:kine/api/authservice.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../ClassAll/Note.dart';
import '../LocalDatabase/DatabaseProvider.dart';
import 'Patient.dart';



class Notes extends StatelessWidget {
  final Map<String, dynamic> user;

  const Notes({required this.user} );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graphique d\'evolution',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Graphique d\'evolution', user: user),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  MyHomePage({required this.title, required this.user});

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Map<String, dynamic>> formattedNotes;
  late Future<List<Map<String, dynamic>>> _notesFuture;
  late List<Map<String, dynamic>> notes;
  late final DatabaseProvider databaseProvider;


  @override
  void initState() {
    super.initState();
    databaseProvider = DatabaseProvider();


    notes = [];
    formattedNotes = [];
    _initializeDatabase();
  }


  Future<void> _initializeDatabase() async {
    await databaseProvider.open();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if( prefs.getString('role') == "kine"){
      List<Note> notes = await databaseProvider.getAllNote(widget.user['id']);
      formattedNotes = notes.map((note) {
        return {
          'note': note.note,
          'date': note.dateTime.toString(),
        };
      }).toList();

      setState(() {

      });
    } else {

      var response = await AuthService().getInfoUser(prefs.getString('token'));

      if (response != null) {
        final responseData = json.decode(response.toString());

        List<Note> notes = await databaseProvider.getAllNote(responseData['id']);
        formattedNotes = notes.map((note) {
          return {
            'note': note.note,
            'date': note.dateTime.toString(),
          };
        }).toList();

        //print("mon id dans auth" + responseData['id']);
      }
    }
    print('print token send${prefs.getString('token')}');

  }


  @override
  Widget build(BuildContext context) {

    final user = widget.user;


    List<charts.Series<Map<String, dynamic>, String>> seriesList = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Notes',
        data: formattedNotes,
        domainFn: (Map<String, dynamic> note, _) => note['date'],
        measureFn: (Map<String, dynamic> note, _) => note['note'],
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Graphique d\'évolution'),
        centerTitle: true,
        automaticallyImplyLeading: true,

      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: charts.BarChart(
          seriesList,
          animate: true,
          barRendererDecorator: charts.BarLabelDecorator<String>(
            labelPosition: charts.BarLabelPosition.inside,
            insideLabelStyleSpec: charts.TextStyleSpec(
              color: charts.MaterialPalette.white,
              fontSize: 12,
            ),
          ),
          domainAxis: charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.black,
                fontSize: 14,
              ),
              lineStyle: charts.LineStyleSpec(
                color: charts.MaterialPalette.gray.shade300,
              ),
            ),
          ),

          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              labelStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.black,
                fontSize: 14,
              ),
              lineStyle: charts.LineStyleSpec(
                color: charts.MaterialPalette.gray.shade300,
              ),
            ),
          ),
        ),
      ),
    );
  }



}