import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'patient.dart';
import 'package:intl/intl.dart';



class Notes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graphique d\'evolution',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Graphique d\'evolution'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required this.title});

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _notesFuture;
   late List<Map<String, dynamic>> notes;

  @override
  void initState() {
    super.initState();
    DatabaseHelper databaseHelper = DatabaseHelper();
  _notesFuture=databaseHelper.getSeances();
    notes = [
      {'note': 3, 'date': '2023-05-01'},
      {'note': 3, 'date': '2023-05-02'},
      {'note': 5, 'date': '2023-05-03'},
      {'note': 7, 'date': '2023-05-04'},

    ];
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<Map<String, dynamic>, String>> seriesList = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Notes',
        data: notes,
        domainFn: (Map<String, dynamic> note, _) => note['date'],
        measureFn: (Map<String, dynamic> note, _) => note['note'],
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Graphique d\'évolution'),
        centerTitle: true,
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
