class Doctor {
  final String id;
  String name;
  String specialty;
  String workingHours;
  List<String> workingDates;

  Doctor({
    required this.id, 
    required this.name, 
    required this.specialty, 
    this.workingHours = '09:00-17:00',
    List<String>? workingDates,
  }) : workingDates = workingDates ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'workingHours': workingHours,
        'workingDates': workingDates,
      };

  static Doctor fromJson(Map<String, dynamic> map) => Doctor(
        id: map['id'] as String,
        name: map['name'] as String,
        specialty: map['specialty'] as String,
        workingHours: (map['workingHours'] as String?) ?? '09:00-17:00',
        workingDates: (map['workingDates'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );

  @override
  String toString() => 'Doctor{id: $id, name: $name, specialty: $specialty, workingHours: $workingHours, workingDates: $workingDates}';
}
