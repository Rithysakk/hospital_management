import 'dart:io';
import 'dart:convert';
import '../../domain/models/room.dart';

class RoomStorage {
  final String path;
  
  RoomStorage([this.path = 'data/room.json']);

  Future<List<Room>> loadRooms() async {
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
      return json.map((j) => Room.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading rooms: $e');
      return [];
    }
  }

  Future<void> saveRooms(List<Room> rooms) async {
    final file = File(path);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final json = rooms.map((r) => r.toJson()).toList();
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(json));
  }
}
