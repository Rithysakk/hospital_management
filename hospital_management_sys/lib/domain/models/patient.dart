class Patient {
  final String id;
  String name;
  DateTime dateOfBirth;
  String contact;
  String gender;

  List<Map<String, String>> medicalRecords = [];

  List<Map<String, String>> appointments = [];

  String? roomId;
  String? roomNumber;
  DateTime? checkInDate;
  DateTime? checkOutDate;

  Patient({required this.id, required this.name, required this.dateOfBirth, required this.contact, this.gender = 'unknown'}) {
    medicalRecords = [];
    appointments = [];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'contact': contact,
        'gender': gender,
        'medicalRecords': medicalRecords,
    'appointments': appointments,
        'roomId': roomId,
    'roomNumber': roomNumber,
        'checkInDate': checkInDate?.toIso8601String(),
        'checkOutDate': checkOutDate?.toIso8601String(),
      };

  static Patient fromJson(Map<String, dynamic> map) => Patient(
        id: map['id'] as String,
        name: map['name'] as String,
        dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
        contact: map['contact'] as String,
        gender: (map['gender'] as String?) ?? 'unknown',
      );

  static Patient fromJsonWithExtras(Map<String, dynamic> map) {
    final p = Patient.fromJson(map);
    final records = (map['medicalRecords'] as List<dynamic>?) ?? [];
    p.medicalRecords = records.map((e) => Map<String, String>.from(e as Map)).toList();
    final appts = (map['appointments'] as List<dynamic>?) ?? [];
    p.appointments = appts.map((e) => Map<String, String>.from(e as Map)).toList();
    p.roomId = map['roomId'] as String?;
    p.roomNumber = map['roomNumber'] as String?;
    p.checkInDate = map['checkInDate'] != null ? DateTime.parse(map['checkInDate'] as String) : null;
    p.checkOutDate = map['checkOutDate'] != null ? DateTime.parse(map['checkOutDate'] as String) : null;
    return p;
  }

  @override
  String toString() => 'Patient{id: $id, name: $name, dob: ${dateOfBirth.toIso8601String()}, contact: $contact}';
}
