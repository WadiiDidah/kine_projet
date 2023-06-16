class Note {
  int? id;
  final String patientid;
  final int note;
  final DateTime dateTime;

  Note({
    this.id,
    required this.patientid,
    required this.note,
    required this.dateTime,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientid': patientid,
      'note': note,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}