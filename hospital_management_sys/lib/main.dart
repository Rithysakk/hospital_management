import 'package:hospital_management_system/data/repositories/patient_file_repository.dart';
import 'package:hospital_management_system/data/repositories/doctor_file_repository.dart';
import 'package:hospital_management_system/data/repositories/room_file_repository.dart';
import 'package:hospital_management_system/domain/services/scheduler.dart';
import 'package:hospital_management_system/ui/console_app.dart';

Future<void> runAppCli() async {
  // Create repositories - they will auto-load from their individual JSON files
  final patientRepo = PatientFileRepository();  // Loads from data/patient.json
  final doctorRepo = DoctorFileRepository();    // Loads from data/doctor.json
  final roomRepo = RoomFileRepository();        // Loads from data/room.json

  // Create scheduler service
  final scheduler = Scheduler(patientRepo: patientRepo, doctorRepo: doctorRepo);

  // Create and run console app
  final app = ConsoleApp(patientRepo: patientRepo, doctorRepo: doctorRepo, scheduler: scheduler, roomRepo: roomRepo);
  await app.run();

  // No need to save - repositories auto-save to their individual files during runtime
}

Future<void> main() async => runAppCli();
