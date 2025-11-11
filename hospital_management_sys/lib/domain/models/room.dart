class Room {
  final String id;
  final String number;
  bool occupied;

  Room({required this.id, required this.number, this.occupied = false});

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'occupied': occupied,
      };

  static Room fromJson(Map<String, dynamic> map) => Room(
        id: map['id'] as String,
        number: map['number'] as String,
        occupied: (map['occupied'] as bool?) ?? false,
      );

  @override
  String toString() => 'Room{id: $id, number: $number, occupied: $occupied}';
}
