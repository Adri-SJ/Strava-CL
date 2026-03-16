class LocationPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationPoint({required this.latitude, required this.longitude, required this.timestamp});

  Map<String, dynamic> toJson() => {
    "latitud": latitude,
    "longitud": longitude,
    "timestamp": timestamp.toIso8601String(),
  };
}