import 'dart:io';
import 'dart:convert';
import '../../domain/models/patient.dart';

class PatientStorage {
  final String path;
  
  PatientStorage([this.path = 'data/patient.json']);

  Future<List<Patient>> loadPatients() async {
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
      return json.map((j) => Patient.fromJsonWithExtras(j as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading patients: $e');
      return [];
    }
  }

  Future<void> savePatients(List<Patient> patients) async {
    final file = File(path);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final json = patients.map((p) => p.toJson()).toList();
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(json));
  }
}