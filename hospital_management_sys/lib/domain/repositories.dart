import 'models/patient.dart';
import 'models/doctor.dart';
import 'models/room.dart';

abstract class PatientRepository {
  Future<void> addPatient(Patient patient);
  Future<Patient?> getById(String id);
  Future<List<Patient>> getAll();
}

abstract class DoctorRepository {
  Future<void> addDoctor(Doctor doctor);
  Future<Doctor?> getById(String id);
  Future<List<Doctor>> getAll();
}

abstract class RoomRepository {
  Future<void> addRoom(Room room);
  Future<List<Room>> getAllRooms();
  Future<Room?> getById(String id);
  Future<void> updateRoom(Room room);
}
