# Hospital Management System (Dart)

A small, educational Hospital Management System written in Dart using object-oriented principles and a layered architecture (domain, data, ui).

Features
- Manage patients
- Manage doctors
- Schedule appointments between patients and doctors with conflict checking
- View doctor schedules

Project structure
- lib/domain: models and service interfaces
- lib/data: in-memory repository implementations
- lib/ui: console-based UI
- bin/main.dart: entry point

How to run
1. Ensure you have the Dart SDK installed (>= 2.18).
2. In the project root run:

```powershell
dart pub get
dart run bin/main.dart
```

This will start a simple console UI.

Notes
- This is a starting scaffold. You can replace the in-memory repositories with DB-backed ones later.
