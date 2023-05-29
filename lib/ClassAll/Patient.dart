class Patient {
  final String id;
  final String name;
  final String phoneNumber;

  Patient({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'numtel': phoneNumber
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'].toString(),
      name: map['name'],
      phoneNumber: map['numtel'],
    );
  }
}