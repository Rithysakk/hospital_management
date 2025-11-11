import '../models/appointment.dart';
import '../repositories.dart';

class Scheduler {
  final PatientRepository patientRepo;
  final DoctorRepository doctorRepo;

  Scheduler({required this.patientRepo, required this.doctorRepo});

  Future<Appointment> scheduleAppointment({required String appointmentId, required String patientId, required String doctorId, required DateTime start}) async {
    final patient = await patientRepo.getById(patientId);
    if (patient == null) throw Exception('Patient not found: $patientId');
    final doctor = await doctorRepo.getById(doctorId);
    if (doctor == null) throw Exception('Doctor not found: $doctorId');

    patient.appointments.add({
      'appointmentId': appointmentId,
      'doctorId': doctor.id,
      'start': start.toIso8601String(),
      'status': AppointmentStatus.scheduled.toString().split('.').last,
    });
    await patientRepo.addPatient(patient);

    // return an Appointment object for convenience
    return Appointment(id: appointmentId, patient: patient, doctor: doctor, start: start);
  }

  Future<List<Appointment>> getDoctorSchedule(String doctorId, DateTime? onDate) async {
    final doctor = await doctorRepo.getById(doctorId);
    if (doctor == null) return [];
    final patients = await patientRepo.getAll();
    final result = <Appointment>[];
    for (final p in patients) {
      for (final a in p.appointments) {
        if (a['doctorId'] == doctorId) {
          final start = DateTime.tryParse(a['start'] ?? '');
          if (start == null) continue;
          if (onDate != null) {
            final sameDay = start.year == onDate.year && start.month == onDate.month && start.day == onDate.day;
            if (!sameDay) continue;
          }
          result.add(Appointment(
            id: a['appointmentId'] ?? '',
            patient: p,
            doctor: doctor,
            start: start,
            status: (() {
              final s = a['status'] ?? 'scheduled';
              return AppointmentStatus.values.firstWhere(
                (e) => e.toString().split('.').last == s,
                orElse: () => AppointmentStatus.scheduled,
              );
            })(),
          ));
        }
      }
    }
    return result;
  }
}
