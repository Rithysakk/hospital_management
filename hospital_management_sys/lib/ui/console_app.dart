import 'dart:io';
import '../domain/models/patient.dart';
import '../domain/models/room.dart';
import '../domain/repositories.dart';
import '../domain/services/scheduler.dart';

class ConsoleApp {
  final PatientRepository patientRepo;
  final DoctorRepository doctorRepo;
  final RoomRepository roomRepo;
  final Scheduler scheduler;

  ConsoleApp({required this.patientRepo, required this.doctorRepo, required this.roomRepo, required this.scheduler});

  Future<void> run() async {
    while (true) {
      print('\nHospital Management System');
      print('1) Register patient (name, gender, contact)');
      print('2) Doctor write medical description for patient');
      print('3) Check-in and assign room');
      print('4) Check-out patient');
      print('5) Search patient by name');
      print('6) View current admitted patients');
      print('7) View all patient records');
      print('0) Exit');
      stdout.write('Choice: ');
      final choice = stdin.readLineSync();
      switch (choice) {
        case '1':
          await _registerPatient();
          break;
        case '2':
          await _writeMedicalDescription();
          break;
        case '3':
          await _checkIn();
          break;
        case '4':
          await _checkOut();
          break;
        case '5':
          await _searchPatientByName();
          break;
        case '6':
          await _viewCurrentAdmitted();
          break;
        case '7':
          await _viewAllPatients();
          break;
        case '0':
          print('Goodbye');
          return;
        default:
          print('Invalid choice');
      }
    }
  }

  Future<void> _registerPatient() async {
    stdout.write('Patient id (leave blank to auto-generate): ');
    var id = stdin.readLineSync() ?? '';
    if (id.isEmpty) id = DateTime.now().millisecondsSinceEpoch.toString();
    stdout.write('Name: ');
    final name = stdin.readLineSync() ?? '';
    stdout.write('Gender (male/female/other): ');
    final gender = stdin.readLineSync() ?? 'unknown';
    stdout.write('Date of birth (YYYY-MM-DD): ');
    final dobStr = stdin.readLineSync() ?? '';
    stdout.write('Contact: ');
    final contact = stdin.readLineSync() ?? '';
    final dob = DateTime.tryParse(dobStr) ?? DateTime(1970);
    final patient = Patient(id: id, name: name, dateOfBirth: dob, contact: contact, gender: gender);
    await patientRepo.addPatient(patient);
    print('Patient registered: $patient');
    
    await _setAppointment(id);
  }

  Future<void> _setAppointment([String? patientId]) async {
    stdout.write('Appointment id: ');
    final aid = stdin.readLineSync() ?? '';
    String pid;
    if (patientId != null) {
      pid = patientId;
      print('Patient id: $pid (auto-filled)');
    } else {
      stdout.write('Patient id: ');
      pid = stdin.readLineSync() ?? '';
    }

    // Show all available doctors
    print('\n=== Available Doctors ===');
    final allDoctors = await doctorRepo.getAll();
    if (allDoctors.isEmpty) {
      print('No doctors available in the hospital.');
      return;
    }

    stdout.write('Start (YYYY-MM-DDTHH:MM, e.g. 2025-11-07T14:30): ');
    final startStr = stdin.readLineSync() ?? '';
    final start = DateTime.tryParse(startStr);
    if (start == null) { print('Invalid start date'); return; }

    // Display doctors with availability info
    for (var i = 0; i < allDoctors.length; i++) {
      final doc = allDoctors[i];
      final schedule = await scheduler.getDoctorSchedule(doc.id, start);
      final isAvailable = schedule.isEmpty;
      
      print('\n${i + 1}. Dr. ${doc.name}');
      print('   Specialty: ${doc.specialty}');
      print('   Working Hours: ${doc.workingHours}');
      print('   Status: ${isAvailable ? "✓ AVAILABLE" : "✗ BUSY (${schedule.length} appointment(s))"}');
    }

    stdout.write('\nEnter doctor name: ');
    final doctorName = stdin.readLineSync() ?? '';
    
    // Find doctor by name (case-insensitive)
    final doctor = allDoctors.where((d) => d.name.toLowerCase() == doctorName.toLowerCase()).firstOrNull;
    
    if (doctor == null) {
      print('Doctor not found. Please enter the exact name.');
      return;
    }

    // Check if doctor is available at this time
    final schedule = await scheduler.getDoctorSchedule(doctor.id, start);
    if (schedule.isNotEmpty) {
      print('Warning: Dr. ${doctor.name} has ${schedule.length} appointment(s) on this date.');
      stdout.write('Continue anyway? (yes/no): ');
      final confirm = stdin.readLineSync()?.toLowerCase() ?? '';
      if (confirm != 'yes' && confirm != 'y') {
        print('Appointment cancelled.');
        return;
      }
    }

    try {
      final appt = await scheduler.scheduleAppointment(appointmentId: aid, patientId: pid, doctorId: doctor.id, start: start);
      print('\n✓ Appointment scheduled successfully!');
      print('  Patient: ${appt.patient.name}');
      print('  Doctor: Dr. ${appt.doctor.name} (${appt.doctor.specialty})');
      print('  Date & Time: ${appt.start}');
    } catch (e) {
      print('Error scheduling: $e');
    }
  }

  Future<void> _writeMedicalDescription() async {
    stdout.write('Patient id: ');
    final pid = stdin.readLineSync() ?? '';
    final patient = await patientRepo.getById(pid);
    if (patient == null) { print('Patient not found'); return; }
    stdout.write('Doctor id (author): ');
    final did = stdin.readLineSync() ?? '';
    final doc = await doctorRepo.getById(did);
    if (doc == null) { print('Doctor not found'); return; }
    stdout.write('Enter medical description: ');
    final desc = stdin.readLineSync() ?? '';
    final entry = {'timestamp': DateTime.now().toIso8601String(), 'doctorId': doc.id, 'text': desc};
    patient.medicalRecords.add(entry);
    await patientRepo.addPatient(patient);
    print('Medical description added to patient ${patient.name}');
  }

  Future<void> _checkIn() async {
    stdout.write('Patient id to check-in: ');
    final pid = stdin.readLineSync() ?? '';
    final patient = await patientRepo.getById(pid);
    if (patient == null) { print('Patient not found'); return; }

    final rooms = await roomRepo.getAllRooms();
    final available = rooms.where((r) => !r.occupied).toList();
    if (available.isEmpty) {
      print('No available rooms.');
      return;
    }
    final avail = available;
    print('Available rooms (number):');
    for (var r in avail) print(' - ${r.number}');
    stdout.write('Enter room number to assign: ');
    final numberInput = stdin.readLineSync() ?? '';
    final room = avail.firstWhere(
      (r) => r.number == numberInput,
      orElse: () => Room(id: '', number: '', occupied: true),
    );
    if (room.id.isEmpty) { print('Room number not found or occupied'); return; }
    if (room.occupied) { print('Room already occupied'); return; }
    room.occupied = true;
    patient.roomId = room.id;
    patient.roomNumber = room.number;
    patient.checkInDate = DateTime.now();
    patient.checkOutDate = null;
    await roomRepo.updateRoom(room);
    await patientRepo.addPatient(patient);
    print('Patient ${patient.name} checked in to room number ${room.number} at ${patient.checkInDate}');
  }

  Future<void> _checkOut() async {
    stdout.write('Patient id to check-out: ');
    final pid = stdin.readLineSync() ?? '';
    final patient = await patientRepo.getById(pid);
    if (patient == null) { print('Patient not found'); return; }
    if (patient.roomId == null) { print('Patient is not checked in'); return; }
    final room = await roomRepo.getById(patient.roomId!);
    if (room != null) {
      room.occupied = false;
      await roomRepo.updateRoom(room);
    }
    patient.checkOutDate = DateTime.now();
    await patientRepo.addPatient(patient);
    print('Patient ${patient.name} checked out at ${patient.checkOutDate}');
  }

  Future<void> _searchPatientByName() async {
    stdout.write('Enter name (partial allowed): ');
    final q = (stdin.readLineSync() ?? '').toLowerCase();
    final all = await patientRepo.getAll();
    final found = all.where((p) => p.name.toLowerCase().contains(q)).toList();
    if (found.isEmpty) { print('No patients found'); return; }
    for (var p in found) _printPatientDetails(p);
  }

  Future<void> _viewCurrentAdmitted() async {
    final all = await patientRepo.getAll();
    final admitted = all.where((p) => p.roomId != null && p.checkOutDate == null).toList();
    if (admitted.isEmpty) { print('No current admitted patients.'); return; }
    for (var p in admitted) _printPatientDetails(p);
  }

  Future<void> _viewAllPatients() async {
    final all = await patientRepo.getAll();
    if (all.isEmpty) { print('No patients found.'); return; }
    for (var p in all) _printPatientDetails(p);
  }

  void _printPatientDetails(Patient p) {
    print('---');
    print('Id: ${p.id}');
    print('Name: ${p.name}');
    print('Gender: ${p.gender}');
    print('Contact: ${p.contact}');
    print('DOB: ${p.dateOfBirth.toIso8601String()}');
    print('RoomId: ${p.roomId}');
  print('RoomNumber: ${p.roomNumber}');
    print('Check-in: ${p.checkInDate}');
    print('Check-out: ${p.checkOutDate}');
    print('Medical Records:');
    for (var r in p.medicalRecords) print(' - [${r['timestamp']}] by ${r['doctorId']}: ${r['text']}');
    print('Appointments:');
    for (var a in p.appointments) print(" - [${a['start']}] apptId=${a['appointmentId']} doctor=${a['doctorId']} status=${a['status']}");
  }

  
}
