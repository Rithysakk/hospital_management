import '../../domain/models/doctor.dart';
import '../../domain/repositories.dart';
import '../storage/doctor_storage.dart';

class DoctorFileRepository implements DoctorRepository {
  final DoctorStorage _storage;
  List<Doctor> _cache = [];
  bool _loaded = false;

  DoctorFileRepository([String path = 'data/doctor.json']) : _storage = DoctorStorage(path);

  Future<void> _ensureLoaded() async {
    if (!_loaded) {
      _cache = await _storage.loadDoctors();
      _loaded = true;
    }
  }

  @override
  Future<void> addDoctor(Doctor doctor) async {
    await _ensureLoaded();
    final idx = _cache.indexWhere((d) => d.id == doctor.id);
    if (idx >= 0) {
      _cache[idx] = doctor;
    } else {
      _cache.add(doctor);
    }
    await _storage.saveDoctors(_cache);
  }

  @override
  Future<List<Doctor>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<Doctor?> getById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
