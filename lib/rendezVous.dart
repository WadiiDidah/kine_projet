import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:kine/bottomBar.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'RendezVousClass.dart';



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
  @override
  void initState() {
    // TODO: implement initState

    selectedEvent = events[selectedDay] ?? events[DateTime.now()] ?? [];
    loadAppointmentsFromDatabase();


    super.initState();
  }


  void supprimerRendezVous()async{
    await DatabaseHelper.instance.deleteAllAppointments();

  }
  void loadAppointmentsFromDatabase() async {
    List<Appointment> appointments = await DatabaseHelper.instance.getAppointments();
    for (var appointment in appointments) {
      DateTime eventDate = DateTime(
          appointment.startDate.year, appointment.startDate.month,
          appointment.startDate.day);
      CleanCalendarEvent event = CleanCalendarEvent(
        '${appointment.nom} ${appointment.prenom}',
        startTime: appointment.startDate,
        endTime: appointment.startTime,
        color: Colors.blue,
      );
      addEvent(eventDate, event);
    }
  }

  void showAlerte(BuildContext context) {
    String eventName = "";
    String patientFirstName = "";
    DateTime startDate = DateTime.now();
    DateTime startTime = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajout d'un nouveau rendez-vous"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nom du patient:'),
                TextFormField(
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Entrez le nom du patient',
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => eventName = value,
                ),
                SizedBox(height: 10),
                Text('Prénom du patient:'),
                TextFormField(
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Entrez le prénom du patient',
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => patientFirstName = value,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 10),
                    Text('Jour de la séance:'),
                  ],
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(DateTime.now().year - 5),
                      lastDate: DateTime(DateTime.now().year + 5),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        startDate = selectedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(startDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 10),
                    Text('Heure de la séance:'),
                  ],
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(startTime),
                    );
                    if (selectedTime != null) {
                      setState(() {
                        startTime = DateTime(
                          startTime.year,
                          startTime.month,
                          startTime.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      DateFormat('HH:mm').format(startTime),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (eventName.isEmpty) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please enter an event name.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }




                // Insérer l'objet Appointment dans la base de données
                Appointment appointment = Appointment(
                  nom: eventName,
                  prenom: patientFirstName,
                  startDate: DateTime.now(),
                  startTime: DateTime.now(),
                );

                int result = await DatabaseHelper.instance.insertAppointment(appointment);
                if (result != 0) {
                  print('Rendez-vous inséré avec succès!');
                } else {
                  print('Échec de l\'insertion du rendez-vous.');
                }
                List<Appointment> appointments = await DatabaseHelper.instance.getAppointments();
                appointments.forEach((appointment) {
                  print('Nom: ${appointment.nom}');
                  print('Prénom: ${appointment.prenom}');
                  print('Date: ${appointment.startDate}');
                  print('Heure: ${appointment.startTime}');
                  print('------------------------');
                });

                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Récapitulatif'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Rendez vous avec  '$eventName' '$patientFirstName'"),
                          Text("Date du rendez-vous : ${DateFormat('yyyy-MM-dd').format(startDate)}"),
                          Text("Heure du redez-vous: ${DateFormat('HH:mm').format(startTime)}"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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
        Builder(
        builder: (BuildContext context) {
      return GestureDetector(
      onTap: () {
      // Gérer le clic sur "Ajouter une tâche"
      // Vous pouvez afficher une boîte de dialogue ou naviguer vers une autre page pour ajouter une tâche.
      showAlerte(widget.scaffoldKey.currentContext!);
      print('Ajouter une tâche');
      },
      child: Container(
      width: double.infinity,
      height: 50,
      color: Colors.blueAccent,
      child: Center(
      child: Text(
      'Ajouter un rendez-vous +',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      ),
      ),
      );
      },
        ),

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
                  dayOfWeekStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.black12,
                    fontWeight: FontWeight.w100,
                  ),
                  bottomBarTextStyle: TextStyle(
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
      bottomNavigationBar: BottomBar(),
    );
  }
}