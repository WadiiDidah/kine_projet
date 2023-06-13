import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kine/ClassAll/TimeSlot.dart';
import 'package:kine/LocalDatabase/DatabaseProvider.dart';
import 'package:kine/RDV/NewAppointmentPage.dart';
import 'package:kine/api/WebSocketProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../ClassAll/Appointment.dart';
import '../CustomBottomNavigationBar.dart';
import '../Introduction.dart';
import '../LocalDatabase/RoleProvider.dart';
import '../api/authservice.dart';
import 'AppointmentUpdateDialog.dart';



class AppointmentsKinePage extends StatefulWidget {
  @override
  _AppointmentsKinePage createState() => _AppointmentsKinePage();
}

class _AppointmentsKinePage extends State<AppointmentsKinePage> {

  late final DatabaseProvider databaseProvider;

  List<Appointment> upcomingAppointments = [];
  List<Appointment> pastAppointments = [];
  List<Appointment> fullCalendarAppointments = [];
  List<Appointment> appointmentRequests = []; // New list for appointment requests

  int _currentIndex = 3;
  bool showUpcomingAppointments = true;
  bool showAppointmentRequests = false;
  bool showAppointmentPass = false;
  bool isRequest = false;
  String selectedButton = 'upcoming'; // Track the selected button

  String patientName = '';

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage:");
      print("onMessage: $message");
      final snackBar =
      SnackBar(content: Text(message.notification?.title ?? ""));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    },
    );
    // TODO: implement initState
    super.initState();
    databaseProvider = DatabaseProvider();
    _initializeDatabase();
    fetchAppointmentsFromDatabase();
  }

  Future<void> _initializeDatabase() async {
    await databaseProvider.open();
  }


  void fetchAppointmentsFromDatabase() async {
    await databaseProvider.open();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Fetch appointments from the database based on user ID and status
    var userId = null; // Replace with your logic to retrieve the user ID


    var response = await AuthService().getInfoUser(prefs.getString('token'));

    if (response != null) {
      final responseData = json.decode(response.toString());
      userId = responseData['id'];
      print(userId);
      //print("mon id dans auth" + responseData['id']);
    }
    //final appointments = await databaseProvider.getAllRdvSortByIdAndSender(userId, 'patient');

    final appointments = await databaseProvider.getAllRdv();



    print("les app" );
    print(appointments);
    // Clear the lists before populating them
    appointmentRequests.clear();
    pastAppointments.clear();
    upcomingAppointments.clear();



    // Filter appointments based on their status and populate the lists
    for (final appointment in appointments) {
      if (appointment.status == 'request') {
        appointmentRequests.add(appointment);
      } else if (appointment.status == 'past' || appointment.status == 'waitforpatient') {
        pastAppointments.add(appointment);
        /**
        print(appointment.endhour);
        print(appointment.starthour);
        print(appointment.status);
        print(appointment.dateTime);
        print(appointment.motif);
        print(appointment.idpatient);
        print(appointment.idkine);
        print(appointment.category);
        print(appointment.title);
        print(appointment.sender);
            **/
      } else if (appointment.status == 'ok'){
        upcomingAppointments.add(appointment);
      }
    }
  }


  List<Appointment> getVisibleAppointments() {
    if (selectedButton == 'requests') {
      return appointmentRequests;
    } else if (selectedButton == 'past') {
      return pastAppointments;
    }else if (selectedButton == 'calendar') {
      // Renvoyer les rendez-vous du calendrier complet du kiné
      return fullCalendarAppointments;
    } else {
      return upcomingAppointments;
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> acceptAppointmentRequest(Appointment appointment) async {
    appointmentRequests.remove(appointment);
    upcomingAppointments.add(appointment);
    await databaseProvider.updateAppointmentStatus(appointment, 'ok');
    setState(() {});
  }

  Future<void> rejectAppointmentRequest(Appointment appointment) async {
    appointmentRequests.remove(appointment);
    await databaseProvider.updateAppointmentStatus(appointment, 'non');
    setState(() {});
  }

  Future<void> deleteAppointment(Appointment appointment) async {

    await databaseProvider.deleteAppointment(appointment);

    setState(() {});
  }

  Future<void> updateAppointment(Appointment appointment) async {

    print("update appointment ");
    await databaseProvider.updateAppointment(appointment);
    setState(() {});
  }


  Future<String> nameById(String id) async {

    print('name by id' + id);
    var response = await AuthService().getInfoUserByID(id);

    if (response != null) {
      final responseData = json.decode(response.toString());
      print("response data " + responseData['name']);
      return responseData['name'];

      //print("mon id dans auth" + responseData['id']);
    } else {
      print("response data  null");
      return 'oknon';
    }
  }

  TimeOfDay parseToTimeOfDay(String timeslot) {
    List<String> timeParts = timeslot.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    TimeOfDay start = TimeOfDay(hour: hour, minute: minute);

    return start;
  }


  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);

    final webSocketProvider = Provider.of<WebSocketProvider>(context);

    // Fetch appointments from the database based on user ID and status

    fetchAppointmentsFromDatabase();

    return Scaffold(

      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              "Mes Rendez-Vous",
            ),
            CupertinoButton(
              child: Icon(
                CupertinoIcons.power,
                size: 24,
              ),
              onPressed: () {
                DatabaseProvider().removeToken();
                webSocketProvider.channel?.sink.close();
                // Rediriger l'utilisateur vers l'écran de connexion
                Navigator.push(context, MaterialPageRoute(builder: (context) => Introduction()));
              },
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 10,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButton = 'upcoming';
                      isRequest = false; // Set showAppointmentRequests to true

                    });
                  },
                  child: Text("À venir"),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButton == 'upcoming'
                        ? Colors.indigo
                        : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButton = 'past';
                      isRequest = false; // Set showAppointmentRequests to true

                    });
                  },
                  child: Text("Passés"),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButton == 'past' ? Colors.indigo : Colors
                        .grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedButton = 'requests';
                      isRequest = true;// Set showAppointmentRequests to true

                    });
                  },
                  child: Text("Demandes"),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButton == 'requests'
                        ? Colors.indigo
                        : Colors.grey,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => KineCalendarPage(appointments: fullCalendarAppointments),),);
                  },
                  child: Text("Calendrier"),
                  style: ElevatedButton.styleFrom(
                    primary: selectedButton == 'calendar' ? Colors.indigo : Colors.grey,
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getVisibleAppointments().length,
              itemBuilder: (context, index)  {
              final appointment = getVisibleAppointments()[index];
              print("on print id avant future builder "+ appointment.idpatient);

              return FutureBuilder<String>(
                future: nameById(appointment.idpatient),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final patientName = snapshot.data;

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Que voulez vous faire ?'),
                            content: Text('Do you want to delete or update the card?'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  deleteAppointment(appointment);
                                  Navigator.pop(context);
                                },
                                child: Text('Delete'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final updatedAppointment = await showDialog<Appointment>(
                                    context: context,
                                    builder: (context) => AppointmentUpdateDialog(appointment: appointment),
                                  );

                                  SharedPreferences prefs = await SharedPreferences.getInstance();

                                  if (updatedAppointment != null) {
                                    print("bon aller on test l'update " + updatedAppointment.starthour.toString());

                                    var starthour = parseToTimeOfDay(updatedAppointment.starthour);
                                    var endhour = parseToTimeOfDay(updatedAppointment.endhour);
                                    TimeSlot t = TimeSlot(startHour: starthour, endHour: endhour);

                                    webSocketProvider.kineDeplaceRdv(appointment, updatedAppointment.dateTime, t, prefs.getString('token'), updatedAppointment.idpatient);

                                    updateAppointment(updatedAppointment);
                                  }

                                  Navigator.pop(context);
                                },
                                child: Text('Update'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                appointment.motif ,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appointment.dateTime.year.toString() +
                                    "/" +
                                    appointment.dateTime.month.toString() +
                                    "/" +
                                    appointment.dateTime.day.toString(),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "De " + appointment.starthour.toString() + " à " + appointment.endhour.toString(),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              if (isRequest) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        acceptAppointmentRequest(appointment);
                                      },
                                      child: const Text("Accept"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        rejectAppointmentRequest(appointment);
                                      },
                                      child: const Text("Reject"),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );

              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NewAppointmentPage(role: 'kine')));
              },
              child: const Text("Proposer un rendez vous"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        role: roleProvider.role,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

