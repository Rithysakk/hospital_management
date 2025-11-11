import '../../domain/models/patient.dart';
import '../../domain/repositories.dart';
import '../storage/patient_storage.dart';

class PatientFileRepository implements PatientRepository {
  final PatientStorage _storage;
  List<Patient> _cache = [];
  bool _loaded = false;

  PatientFileRepository([String path = 'data/patient.json']) : _storage = PatientStorage(path);

  Future<void> _ensureLoaded() async {
    if (!_loaded) {
      _cache = await _storage.loadPatients();
      _loaded = true;
    }
  }

  @override
  Future<void> addPatient(Patient patient) async {
    await _ensureLoaded();
    final idx = _cache.indexWhere((p) => p.id == patient.id);
    if (idx >= 0) {
      _cache[idx] = patient;
    } else {
      _cache.add(patient);
    }
    await _storage.savePatients(_cache);
  }

  @override
  Future<List<Patient>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<Patient?> getById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
