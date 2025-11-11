import 'dart:io';
import 'dart:convert';
import '../../domain/models/doctor.dart';

class DoctorStorage {
  final String path;
  
  DoctorStorage([this.path = 'data/doctor.json']);

  Future<List<Doctor>> loadDoctors() async {
    final file = File(path);
    if (!await file.exists()) {
      final dir = Directory(path).parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return [];
    }

    try {
      final text = await file.readAsString();
      final json = jsonDecode(text) as List<dynamic>;
      return json.map((j) {
        final map = j as Map<String, dynamic>;
        final workingDates = (map['workingDates'] as List<dynamic>?)?.map((d) => d as String).toList() ?? [];
        return Doctor(
          id: map['id'] as String,
          name: map['name'] as String,
          specialty: map['specialty'] as String,
          workingHours: map['workingHours'] as String? ?? '09:00-17:00',
          workingDates: workingDates,
        );
      }).toList();
    } catch (e) {
      print('Error loading doctors: $e');
      return [];
    }
  }

  Future<void> saveDoctors(List<Doctor> doctors) async {
    final file = File(path);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final json = doctors.map((d) => {
      'id': d.id,
      'name': d.name,
      'specialty': d.specialty,
      'workingHours': d.workingHours,
      'workingDates': d.workingDates,
    }).toList();

    await file.writeAsString(JsonEncoder.withIndent('  ').convert(json));
  }
}