import '../../domain/models/patient.dart';
import '../../domain/models/doctor.dart';
import '../../domain/repositories.dart';

class InMemoryPatientRepository implements PatientRepository {
  final Map<String, Patient> _store = {};

  @override
  Future<void> addPatient(Patient patient) async {
    _store[patient.id] = patient;
  }

  @override
  Future<List<Patient>> getAll() async => _store.values.toList();

  @override
  Future<Patient?> getById(String id) async => _store[id];
}

class InMemoryDoctorRepository implements DoctorRepository {
  final Map<String, Doctor> _store = {};

  @override
  Future<void> addDoctor(Doctor doctor) async {
    _store[doctor.id] = doctor;
  }

  @override
  Future<Doctor?> getById(String id) async => _store[id];

  @override
  Future<List<Doctor>> getAll() async => _store.values.toList();
}
