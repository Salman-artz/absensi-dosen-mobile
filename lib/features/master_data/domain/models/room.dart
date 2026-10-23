class Room {
  final String roomId;
  final String name;
  final String? building;

  Room({
    required this.roomId,
    required this.name,
    this.building,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomId: json['id'] ?? json['roomId'] ?? '',
        name: json['name'] ?? '',
        building: json['building'],
      );

  Map<String, dynamic> toJson() => {
        'id': roomId,
        'name': name,
        if (building != null) 'building': building,
      };
}
