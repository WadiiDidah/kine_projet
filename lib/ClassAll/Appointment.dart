import 'package:flutter/material.dart';

class Appointment {
  int? id;
  final String title;
  final String motif;
  final String category;
  final String idpatient;
  final String idkine;
  final DateTime dateTime;
  final String starthour;
  final String endhour;
  late final String status;
  final String sender;


  Appointment({
    this.id,
    required this.starthour,
    required this.endhour,
    required this.title,
    required this.motif,
    required this.category,
    required this.dateTime,
    required this.idkine,
    required this.idpatient,
    required this.status,
    required this.sender,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'motif': motif,
      'starthour': starthour,
      'endhour': endhour,
      'category': category,
      'dateTime': dateTime.toIso8601String(),
      'idkine': idkine,
      'idpatient': idpatient,
      'status': status,
      'sender': sender
    };
  }

  Appointment copyWith({
    String? hour,
    String? motif,
    String? category,
    DateTime? dateTime,
    String? starthour,
    String? endhour,
    // Other fields...
  }) {
    return Appointment(
      id: this.id,
      title: this.title,
      motif: motif ?? this.motif,
      category: category ?? this.category,
      dateTime: dateTime ?? this.dateTime,
      starthour: starthour ?? this.starthour,
      endhour: endhour ?? this.endhour,
      idkine: this.idkine,
      idpatient: this.idpatient,
      status: this.status,
      sender: this.sender,
      // Other field assignments...
    );
  }
}