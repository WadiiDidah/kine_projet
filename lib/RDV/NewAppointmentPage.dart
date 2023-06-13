import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kine/api/authservice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../ClassAll/Patient.dart';
import '../ClassAll/TimeSlot.dart';
import '../api/WebSocketProvider.dart';
import 'TimeSlotCheckbox.dart';
import 'package:intl/intl.dart';




class NewAppointmentPage extends StatefulWidget {
  final String role;

  NewAppointmentPage({required this.role});

  @override
  _NewAppointmentPageState createState() => _NewAppointmentPageState();
}

class _NewAppointmentPageState extends State<NewAppointmentPage> {
  int currentStep = 0;
  List<String> categories = ['Jambe', 'Corps entier', 'Bras'];
  String selectedCategory = '';
  TimeSlot? selectedHour;
  String motif = '';
  List<TimeOfDay> convertedTimeSlots = [];

  List<TimeSlot> timeSlots = [
    TimeSlot(startHour: TimeOfDay(hour: 10, minute: 0), endHour: TimeOfDay(hour: 11, minute: 0)),
    TimeSlot(startHour: TimeOfDay(hour: 11, minute: 0), endHour: TimeOfDay(hour: 12, minute: 0)),
    TimeSlot(startHour: TimeOfDay(hour: 14, minute: 0), endHour: TimeOfDay(hour: 15, minute: 0)),
    TimeSlot(startHour: TimeOfDay(hour: 16, minute: 0), endHour: TimeOfDay(hour: 17, minute: 0)),
    TimeSlot(startHour: TimeOfDay(hour: 18, minute: 0), endHour: TimeOfDay(hour: 19, minute: 0)),
    // Add more time slots as needed
  ];


  bool isSearchResultsVisible = false; // Track the visibility of search results

  CalendarController _calendarController = CalendarController();
  DateTime? selectedDate;
  bool isDaySelected = false;
  String selectedPatient = ''; // Variable to hold the selected patient

  late List<Patient> searchResults;

  void _performSearch(String searchQuery) async {
    // Call the AuthService().getAllPatient() function with the search query
    // Pass the search query to the server-side and handle the response
    var response = await AuthService().getAllPatient(searchQuery);

    if (response != null) {
      print('response not null');
      final responseData = json.decode(response.toString());
      if(responseData['success']){
        // Extract the list of users from the response
        final userList = responseData['users'];

        searchResults = userList.map<Patient>((user) => Patient.fromMap(user)).toList();
      } else {
        print("reponse fausse, rien trouvé");
      }


      //print("mon id dans auth" + responseData['id']);
    }else{
      print("probleme avec la reponse");
    }


  }

  List<Widget> buildChoiceChips() {
    List<Widget> choiceChips = [];

    for (var timeSlot in timeSlots) {
      if (selectedDate?.year != null &&
          selectedDate?.month != null &&
          selectedDate?.day != null) {
        var response = AuthService().isTimeSlotTaken(
          timeSlot,
          selectedDate!.year.toString(),
          selectedDate!.month.toString(),
          selectedDate!.day.toString(),
        );

        if (response != null) {
          final responseData = json.decode(response.toString());
          print(responseData);
          if (responseData['success']) {
            print("success");
          } else {
            print("not success");
            choiceChips.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ChoiceChip(
                  label: Text("ok"),
                  selected: selectedHour == timeSlot,
                  onSelected: (selected) {
                    setState(() {
                      selectedHour = selected ? timeSlot : null;
                    });
                  },
                ),
              ),
            );
          }
        }
      } else {
        // Handle the case when selectedDate is not fully set
      }
    }

    return choiceChips;
  }

  void _nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      currentStep--;
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  void initState()  {
    super.initState();

    searchResults = [];
  }


  @override
  Widget build(BuildContext context) {
    final webSocketProvider = Provider.of<WebSocketProvider>(context);
    final messages = webSocketProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Demande de rendez-vous'),
        centerTitle: true,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep == 0 && selectedCategory.isNotEmpty) {
            _nextStep();
          } else if (currentStep == 1 && selectedDate != null) {
            if (widget.role == 'kine') {
              // If the user is a kine, go to the next step to select a patient
              _nextStep();
            } else {
              // If the user is not a kine, directly submit the appointment request
              _submitAppointmentRequest();
            }
          } else if (currentStep == 2 && selectedPatient.isNotEmpty) {
            // Submit the appointment request
            _submitAppointmentRequest();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            _previousStep();
          }
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(
                  currentStep == 2 ? 'Finish' : 'Next',
                ),
              ),
              const SizedBox(width: 16),
              if (currentStep > 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Previous'),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: Text('Catégorie'),
            isActive: currentStep == 0,
            content: Column(
              children: [
                Text('Sélectionnez une catégorie :'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Option 1: Select from predefined categories
                    ...categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = selected ? category : '';
                            });
                          },
                        ),
                      );
                    }).toList(),
                    // Option 2: Enter custom category
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Builder(
                        builder: (context) {
                          return ChoiceChip(
                            label: Text('Autre'),
                            selected: selectedCategory == 'Autre',
                            onSelected: (selected) {
                              if (selected) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String newCategory = '';
                                    return AlertDialog(
                                      title: Text('Nouvelle catégorie'),
                                      content: TextField(
                                        onChanged: (value) {
                                          newCategory = value;
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              selectedCategory = newCategory;
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text('Valider'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  selectedCategory = '';
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Motif de la visite :'),
                SizedBox(height: 8),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      motif = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Entrez le motif de la visite',
                    border: OutlineInputBorder(),
                  ),
                )
              ],
            ),
          ),

          Step(
            title: Text('Date'),
            isActive: currentStep == 1,
            content: Column(
              children: [
                Text('Sélectionnez une date :'),
                SizedBox(height: 25),
                TableCalendar(
                  calendarController: _calendarController,
                  onDaySelected: (DateTime date, List<dynamic> events, List<dynamic> holidays) {
                    setState(() {
                      selectedDate = DateTime(date.year, date.month, date.day);
                    });
                  },
                ),
                const SizedBox(height: 50),
                const Text('Sélectionnez les horaires disponibles :'),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: timeSlots.map((timeSlot) {
                      if (selectedDate != null && timeSlot != null) {
                        final startHour = timeSlot.startHour;
                        final endHour = timeSlot.endHour;

                        // Convert startHour and endHour to formatted strings
                        final startTime = '${startHour.hour}:${startHour.minute.toString().padLeft(2, '0')}';
                        final endTime = '${endHour.hour}:${endHour.minute.toString().padLeft(2, '0')}';


                        return FutureBuilder(
                          future: AuthService().isTimeSlotTaken(
                            timeSlot,
                            selectedDate?.year.toString(),
                            selectedDate?.month.toString(),
                            selectedDate?.day.toString(),
                          ),
                          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // Show a loading indicator while waiting for the response
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              // Handle any errors that occurred during the async operation
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.data == true) {
                              // Time slot is taken
                              print("data taken");
                              return Container(); // Return an empty container or any other widget as needed
                            } else {
                              print("slot available");
                              // Time slot is available
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: ChoiceChip(
                                  label: Text('$startTime - $endTime'),
                                  selected: selectedHour == timeSlot,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedHour = selected ? timeSlot : null;
                                      print(timeSlot.endHour);
                                    });
                                  },
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return Container(); // Return an empty container if the conditions are not met
                      }
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (widget.role == 'kine')
            Step(
            title: Text('Patient'),
            isActive: currentStep == 2,
            content: SizedBox(
              height: MediaQuery.of(context).size.height, // Add a height constraint
              child: Column(
                children: [
                  const Text('Sélectionnez un patient :'),
                  const SizedBox(height: 25),
                  // Add your patient selection widget here (e.g., search bar, dropdown)
                  // and assign the selected patient to the 'selectedPatient' variable
                  // Example:
                  TextField(
                    onChanged: (value) async {
                      if (value.isNotEmpty) {
                        // Call the search function when the search query changes
                        _performSearch(value);

                        setState(() {
                          isSearchResultsVisible = true;
                        });
                      } else {
                        setState(() {
                          isSearchResultsVisible = false;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Patient',
                    ),
                  ),
                  Visibility(
                    visible: isSearchResultsVisible,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchResults[index];
                          return ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  selectedPatient = user.id;
                                });

                                // Rest of your code that uses the render object
                                // ...
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAppointmentRequest() {
    // Perform the appointment request submission
    print("demande ok");
    print("selected hour" + selectedHour!.toString());
    print("motif" + motif);
    print("date ${selectedDate!}");
    print("patient $selectedPatient");
    print("demande ok");
    // Afficher une boîte de dialogue ou une confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Demande de rendez-vous'),
        content: Text('Votre demande de rendez-vous a été soumise avec succès.'),
        actions: [
          TextButton(
            onPressed: () async {
              final webSocketProvider = Provider.of<WebSocketProvider>(context, listen: false);

              SharedPreferences prefs = await SharedPreferences.getInstance();

              if (widget.role == 'kine'){
                webSocketProvider.sendRdvToPatient(selectedDate!, selectedHour!, selectedCategory, prefs.getString('token'), motif, selectedPatient);
              }else{
                webSocketProvider.sendRdvToKine(selectedDate!, selectedHour!, selectedCategory, prefs.getString('token'), motif);

              }

              Navigator.of(context).pop();
              // Naviguer vers une autre page ou effectuer une autre action
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
