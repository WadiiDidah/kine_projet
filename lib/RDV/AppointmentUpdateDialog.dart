import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ClassAll/Appointment.dart';
import 'package:intl/intl.dart';


class AppointmentUpdateDialog extends StatefulWidget {
  final Appointment appointment;

  AppointmentUpdateDialog({required this.appointment});


  @override
  _AppointmentUpdateDialogState createState() => _AppointmentUpdateDialogState();
}

class _AppointmentUpdateDialogState extends State<AppointmentUpdateDialog> {
  late DateTime selectedDate;
  late String selectedStartTime;
  late String selectedEndTime;


  @override
  void initState() {
    super.initState();
    selectedDate = widget.appointment.dateTime;
    selectedStartTime = "";
    selectedEndTime = "";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null && pickedTime != selectedStartTime) {
      setState(() {
        selectedStartTime = DateFormat('HH:mm').format(DateTime(2000, 1, 1, pickedTime.hour, pickedTime.minute));
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (pickedTime != null && pickedTime != selectedEndTime) {
      setState(() {
        selectedEndTime = DateFormat('HH:mm').format(DateTime(2000, 1, 1, pickedTime.hour, pickedTime.minute));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: const Text('Select Date'),
          ),
          const SizedBox(height: 8),
          Text('Selected Date: ${selectedDate.toString()}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _selectStartTime(context),
            child: const Text('Select Start Time'),
          ),
          const SizedBox(height: 8),
          Text('Selected Start Time: ${selectedStartTime}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _selectEndTime(context),
            child: const Text('Select End Time'),
          ),
          const SizedBox(height: 8),
          Text('Selected End Time: ${selectedEndTime}'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final updatedAppointment = widget.appointment.copyWith(
              dateTime: DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
              ),
              starthour: selectedStartTime,
              endhour: selectedEndTime,
            );

            Navigator.pop(context, updatedAppointment);
          },
          child: Text('Update'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

