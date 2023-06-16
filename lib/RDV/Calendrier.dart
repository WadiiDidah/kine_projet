import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:kine/LocalDatabase/DatabaseProvider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import '../ClassAll/Appointment.dart';



class DemoApp extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  _DemoAppState createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {

  late DateTime selectedDay = DateTime.now();
  late List <CleanCalendarEvent> selectedEvent;

  final Map<DateTime,List<CleanCalendarEvent>> events = {
    DateTime (DateTime.now().year,DateTime.now().month,DateTime.now().day):
    [
      CleanCalendarEvent('Event A',
          startTime: DateTime(
              DateTime.now().year,DateTime.now().month,DateTime.now().day,10,0),
          endTime:  DateTime(
              DateTime.now().year,DateTime.now().month,DateTime.now().day,12,0),
          description: 'A special event',
          color: Colors.blue),
    ],


    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2):
    [
      CleanCalendarEvent('Event B',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 10, 0),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 12, 0),
          color: Colors.orange),
      CleanCalendarEvent('Event C',
          startTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 14, 30),
          endTime: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 17, 0),
          color: Colors.pink),
    ],
    DateTime(2023,05,19):
    [
      CleanCalendarEvent('Rendez vous avec Wadii Didah',
          startTime: DateTime(2023,05,
              19, 10, 0),
          endTime: DateTime(2023,05,
              19, 12, 0),
          color: Colors.orange),

    ],

  };

  void addEvent(DateTime date, CleanCalendarEvent event) {
    setState(() {
      if (events.containsKey(date)) {
        events[date]!.add(event);
      } else {
        events[date] = [event];
      }

      selectedEvent = events[date] ?? [];
    });
  }
  void _handleData(date){
    setState(() {
      selectedDay = date;
      selectedEvent = events[selectedDay] ?? [];
    });
    print(selectedDay);
  }

  late final DatabaseProvider databaseProvider;

  @override
  void initState() {
    // TODO: implement initState


    selectedEvent = events[selectedDay] ?? events[DateTime.now()] ?? [];

    super.initState();
    databaseProvider = DatabaseProvider();
    _initializeDatabase();
    loadAppointmentsFromDatabase();
  }



  Future<void> _initializeDatabase() async {
    await databaseProvider.open();
  }

  void loadAppointmentsFromDatabase() async {
    await databaseProvider.open();

    List<Appointment> appointments = await databaseProvider.getAllRdv();
    for (var appointment in appointments) {
      print("add app dans calendar");
      List<String> timestart = appointment.starthour.split(":");
      List<String> timeend = appointment.endhour.split(":");
      int starthour = int.parse(timestart[0]);
      int startminute = int.parse(timestart[1]);

      int endhour = int.parse(timeend[0]);
      int endminute = int.parse(timeend[1]);

      DateTime eventDate = appointment.dateTime;
      DateTime start = DateTime(appointment.dateTime.year, appointment.dateTime.month, appointment.dateTime.day, starthour, startminute);
      DateTime end = DateTime(appointment.dateTime.year, appointment.dateTime.month, appointment.dateTime.day, endhour, endminute);
      CleanCalendarEvent event = CleanCalendarEvent(
        '${appointment.sender} ${appointment.title}',
        startTime: start,
        endTime: end,
        color: Colors.blue,
      );
      addEvent(eventDate, event);
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:widget.scaffoldKey,
      appBar: AppBar(
        title: Text('Rendez-vous'),
        centerTitle: true,
      ),
      body:  SafeArea(
        child:Column(
            children:[


              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
                    child: Calendar(
                      startOnMonday: true,
                      selectedColor: Colors.blue,
                      todayColor: Colors.red,
                      eventColor: Colors.green,
                      eventDoneColor: Colors.amber,
                      bottomBarColor: Colors.deepOrange,
                      onRangeSelected: (range) {
                        print('selected Day ${range.from},${range.to}');
                      },
                      onDateSelected: (date) {
                        return _handleData(date);
                      },
                      events: events,
                      isExpanded: true,
                      dayOfWeekStyle: const TextStyle(
                        fontSize: 15,
                        color: Colors.black12,
                        fontWeight: FontWeight.w800,
                      ),
                      bottomBarTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      hideBottomBar: false,
                      hideArrows: false,
                      weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],

                    ),
                  ),
                ),
              ),

            ]),
      ),

    );
  }
}