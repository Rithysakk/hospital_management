import '../../domain/models/room.dart';
import '../../domain/repositories.dart';
import '../storage/room_storage.dart';

class RoomFileRepository implements RoomRepository {
  final RoomStorage _storage;
  List<Room> _cache = [];
  bool _loaded = false;

  RoomFileRepository([String path = 'data/room.json']) : _storage = RoomStorage(path);

  Future<void> _ensureLoaded() async {
    if (!_loaded) {
      _cache = await _storage.loadRooms();
      _loaded = true;
    }
  }

  @override
  Future<void> addRoom(Room room) async {
    await _ensureLoaded();
    final idx = _cache.indexWhere((r) => r.id == room.id);
    if (idx >= 0) {
      _cache[idx] = room;
    } else {
      _cache.add(room);
    }
    await _storage.saveRooms(_cache);
  }

  @override
  Future<List<Room>> getAllRooms() async {
    await _ensureLoaded();
    return List.unmodifiable(_cache);
  }

  @override
  Future<Room?> getById(String id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateRoom(Room room) async {
    await _ensureLoaded();
    final idx = _cache.indexWhere((r) => r.id == room.id);
    if (idx >= 0) {
      _cache[idx] = room;
      await _storage.saveRooms(_cache);
    }
  }
}
