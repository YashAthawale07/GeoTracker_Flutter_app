class Geofence {
  final double latitude;
  final double longitude;
  final double radius;

  Geofence({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}

