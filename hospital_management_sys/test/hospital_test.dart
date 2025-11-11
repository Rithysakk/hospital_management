import 'package:test/test.dart';
import 'package:hospital_management_system/data/repositories/in_memory_repository.dart';
import 'package:hospital_management_system/domain/models/patient.dart';
import 'package:hospital_management_system/domain/models/doctor.dart';
import 'package:hospital_management_system/domain/models/room.dart';
import 'package:hospital_management_system/domain/models/appointment.dart';
import 'package:hospital_management_system/domain/services/scheduler.dart';

void main() {
  group('Patient Repository Tests', () {
    test('add and retrieve patient by id', () async {
      final repo = InMemoryPatientRepository();
      final patient = Patient(
        id: 'p1',
        name: 'Alice Smith',
        dateOfBirth: DateTime(1990, 5, 15),
        contact: '555-1234',
        gender: 'female',
      );

      await repo.addPatient(patient);
      final retrieved = await repo.getById('p1');

      expect(retrieved, isNotNull);
      expect(retrieved?.name, equals('Alice Smith'));
      expect(retrieved?.gender, equals('female'));
    });

    test('get all patients', () async {
      final repo = InMemoryPatientRepository();
      final p1 = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      final p2 = Patient(id: 'p2', name: 'Bob', dateOfBirth: DateTime(1985, 2, 2), contact: '222');

      await repo.addPatient(p1);
      await repo.addPatient(p2);

      final all = await repo.getAll();
      expect(all.length, equals(2));
      expect(all.map((p) => p.id).toList(), containsAll(['p1', 'p2']));
    });

    test('update existing patient', () async {
      final repo = InMemoryPatientRepository();
      final patient = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');

      await repo.addPatient(patient);
      patient.name = 'Alice Updated';
      await repo.addPatient(patient);

      final retrieved = await repo.getById('p1');
      expect(retrieved?.name, equals('Alice Updated'));
    });

    test('return null for non-existent patient', () async {
      final repo = InMemoryPatientRepository();
      final retrieved = await repo.getById('nonexistent');
      expect(retrieved, isNull);
    });
  });

  group('Doctor Repository Tests', () {
    test('add and retrieve doctor by id', () async {
      final repo = InMemoryDoctorRepository();
      final doctor = Doctor(
        id: 'd1',
        name: 'Dr. Smith',
        specialty: 'Cardiology',
        workingHours: '09:00-17:00',
      );

      await repo.addDoctor(doctor);
      final retrieved = await repo.getById('d1');

      expect(retrieved, isNotNull);
      expect(retrieved?.name, equals('Dr. Smith'));
      expect(retrieved?.specialty, equals('Cardiology'));
    });

    test('get all doctors', () async {
      final repo = InMemoryDoctorRepository();
      final d1 = Doctor(id: 'd1', name: 'Dr. Smith', specialty: 'Cardiology');
      final d2 = Doctor(id: 'd2', name: 'Dr. Jones', specialty: 'Neurology');

      await repo.addDoctor(d1);
      await repo.addDoctor(d2);

      final all = await repo.getAll();
      expect(all.length, equals(2));
    });

    test('return null for non-existent doctor', () async {
      final repo = InMemoryDoctorRepository();
      final retrieved = await repo.getById('nonexistent');
      expect(retrieved, isNull);
    });
  });

  group('Room Model Tests', () {
    test('create room with default values', () {
      final room = Room(id: 'r1', number: '101');
      expect(room.id, equals('r1'));
      expect(room.number, equals('101'));
      expect(room.occupied, isFalse);
    });

    test('create occupied room', () {
      final room = Room(id: 'r2', number: '102', occupied: true);
      expect(room.occupied, isTrue);
    });

    test('room toJson and fromJson', () {
      final room = Room(id: 'r3', number: '103', occupied: true);
      final json = room.toJson();
      final restored = Room.fromJson(json);

      expect(restored.id, equals('r3'));
      expect(restored.number, equals('103'));
      expect(restored.occupied, isTrue);
    });
  });

  group('Appointment Model Tests', () {
    test('create appointment with default status', () {
      final patient = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      final doctor = Doctor(id: 'd1', name: 'Dr. Bob', specialty: 'Cardio');
      final appt = Appointment(
        id: 'a1',
        patient: patient,
        doctor: doctor,
        start: DateTime(2025, 11, 10, 14, 0),
      );

      expect(appt.status, equals(AppointmentStatus.scheduled));
    });

    test('appointment toJson', () {
      final patient = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      final doctor = Doctor(id: 'd1', name: 'Dr. Bob', specialty: 'Cardio');
      final appt = Appointment(
        id: 'a1',
        patient: patient,
        doctor: doctor,
        start: DateTime(2025, 11, 10, 14, 0),
        status: AppointmentStatus.completed,
      );

      final json = appt.toJson();
      expect(json['id'], equals('a1'));
      expect(json['patientId'], equals('p1'));
      expect(json['doctorId'], equals('d1'));
      expect(json['status'], equals('completed'));
    });
  });

  group('Scheduler Tests', () {
    test('schedule appointment without conflict', () async {
      final patientRepo = InMemoryPatientRepository();
      final doctorRepo = InMemoryDoctorRepository();
      final scheduler = Scheduler(patientRepo: patientRepo, doctorRepo: doctorRepo);

      final p = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      final d = Doctor(id: 'd1', name: 'Dr Bob', specialty: 'Cardio');
      await patientRepo.addPatient(p);
      await doctorRepo.addDoctor(d);

      final appt = await scheduler.scheduleAppointment(
        appointmentId: 'a1',
        patientId: 'p1',
        doctorId: 'd1',
        start: DateTime(2025, 11, 07, 10, 0),
      );

      expect(appt.patient.id, equals('p1'));
      expect(appt.doctor.id, equals('d1'));
      expect(appt.status, equals(AppointmentStatus.scheduled));
    });

    test('schedule appointment throws error for non-existent patient', () async {
      final patientRepo = InMemoryPatientRepository();
      final doctorRepo = InMemoryDoctorRepository();
      final scheduler = Scheduler(patientRepo: patientRepo, doctorRepo: doctorRepo);

      final d = Doctor(id: 'd1', name: 'Dr Bob', specialty: 'Cardio');
      await doctorRepo.addDoctor(d);

      expect(
        () async => await scheduler.scheduleAppointment(
          appointmentId: 'a1',
          patientId: 'nonexistent',
          doctorId: 'd1',
          start: DateTime(2025, 11, 07, 10, 0),
        ),
        throwsException,
      );
    });

    test('schedule appointment throws error for non-existent doctor', () async {
      final patientRepo = InMemoryPatientRepository();
      final doctorRepo = InMemoryDoctorRepository();
      final scheduler = Scheduler(patientRepo: patientRepo, doctorRepo: doctorRepo);

      final p = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      await patientRepo.addPatient(p);

      expect(
        () async => await scheduler.scheduleAppointment(
          appointmentId: 'a1',
          patientId: 'p1',
          doctorId: 'nonexistent',
          start: DateTime(2025, 11, 07, 10, 0),
        ),
        throwsException,
      );
    });

    test('get doctor schedule for specific date', () async {
      final patientRepo = InMemoryPatientRepository();
      final doctorRepo = InMemoryDoctorRepository();
      final scheduler = Scheduler(patientRepo: patientRepo, doctorRepo: doctorRepo);

      final p1 = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      final p2 = Patient(id: 'p2', name: 'Bob', dateOfBirth: DateTime(1985, 2, 2), contact: '222');
      final d = Doctor(id: 'd1', name: 'Dr Bob', specialty: 'Cardio');

      await patientRepo.addPatient(p1);
      await patientRepo.addPatient(p2);
      await doctorRepo.addDoctor(d);

      await scheduler.scheduleAppointment(
        appointmentId: 'a1',
        patientId: 'p1',
        doctorId: 'd1',
        start: DateTime(2025, 11, 10, 10, 0),
      );

      await scheduler.scheduleAppointment(
        appointmentId: 'a2',
        patientId: 'p2',
        doctorId: 'd1',
        start: DateTime(2025, 11, 10, 14, 0),
      );

      await scheduler.scheduleAppointment(
        appointmentId: 'a3',
        patientId: 'p1',
        doctorId: 'd1',
        start: DateTime(2025, 11, 11, 10, 0),
      );

      final schedule = await scheduler.getDoctorSchedule('d1', DateTime(2025, 11, 10));
      expect(schedule.length, equals(2));
    });

    test('get all doctor appointments without date filter', () async {
      final patientRepo = InMemoryPatientRepository();
      final doctorRepo = InMemoryDoctorRepository();
      final scheduler = Scheduler(patientRepo: patientRepo, doctorRepo: doctorRepo);

      final p = Patient(id: 'p1', name: 'Alice', dateOfBirth: DateTime(1990, 1, 1), contact: '111');
      final d = Doctor(id: 'd1', name: 'Dr Bob', specialty: 'Cardio');

      await patientRepo.addPatient(p);
      await doctorRepo.addDoctor(d);

      await scheduler.scheduleAppointment(
        appointmentId: 'a1',
        patientId: 'p1',
        doctorId: 'd1',
        start: DateTime(2025, 11, 10, 10, 0),
      );

      await scheduler.scheduleAppointment(
        appointmentId: 'a2',
        patientId: 'p1',
        doctorId: 'd1',
        start: DateTime(2025, 11, 15, 14, 0),
      );

      final schedule = await scheduler.getDoctorSchedule('d1', null);
      expect(schedule.length, equals(2));
    });
  });

  group('Patient Model Tests', () {
    test('patient toJson and fromJson', () {
      final patient = Patient(
        id: 'p1',
        name: 'Alice',
        dateOfBirth: DateTime(1990, 5, 15),
        contact: '555-1234',
        gender: 'female',
      );

      final json = patient.toJson();
      final restored = Patient.fromJson(json);

      expect(restored.id, equals('p1'));
      expect(restored.name, equals('Alice'));
      expect(restored.gender, equals('female'));
    });

    test('patient with medical records and appointments', () {
      final patient = Patient(
        id: 'p1',
        name: 'Alice',
        dateOfBirth: DateTime(1990, 1, 1),
        contact: '111',
      );

      patient.medicalRecords.add({
        'timestamp': DateTime.now().toIso8601String(),
        'doctorId': 'd1',
        'text': 'Regular checkup',
      });

      patient.appointments.add({
        'appointmentId': 'a1',
        'doctorId': 'd1',
        'start': DateTime(2025, 11, 10).toIso8601String(),
        'status': 'scheduled',
      });

      expect(patient.medicalRecords.length, equals(1));
      expect(patient.appointments.length, equals(1));
    });
  });
}

