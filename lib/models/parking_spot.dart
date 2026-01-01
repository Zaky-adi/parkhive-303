class ParkingSpot {
  final String name;
  final double lat;
  final double lng;
  final int usedSlots;
  final int totalSlots;

  ParkingSpot({
    required this.name,
    required this.lat,
    required this.lng,
    required this.usedSlots,
    required this.totalSlots,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      name: json['name'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      usedSlots: json['usedSlots'],
      totalSlots: json['totalSlots'],
    );
  }
}
