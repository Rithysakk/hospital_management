import 'doctor.dart';
import 'patient.dart';

enum AppointmentStatus { scheduled, completed, cancelled }

class Appointment {
  final String id;
  final Patient patient;
  final Doctor doctor;
  final DateTime start;
  AppointmentStatus status;

  Appointment({required this.id, required this.patient, required this.doctor, required this.start, this.status = AppointmentStatus.scheduled});

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patient.id,
        'doctorId': doctor.id,
        'start': start.toIso8601String(),
        'status': status.toString().split('.').last,
      };

  static Appointment fromJson(Map<String, dynamic> map, Patient patient, Doctor doctor) {
    final statusStr = (map['status'] as String?) ?? 'scheduled';
    final status = AppointmentStatus.values.firstWhere((e) => e.toString().split('.').last == statusStr, orElse: () => AppointmentStatus.scheduled);
    return Appointment(
      id: map['id'] as String,
      patient: patient,
      doctor: doctor,
      start: DateTime.parse(map['start'] as String),
      status: status,
    );
  }

  @override
  String toString() => 'Appointment{id: $id, patient: ${patient.name}, doctor: ${doctor.name}, start: $start, status: $status}';
}
