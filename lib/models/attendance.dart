class Attendance {
  final String empId;
  final double lat;
  final double lon;

  Attendance({required this.empId, required this.lat, required this.lon});

  Map<String, dynamic> toJson() {
    return {'empId': empId, 'lat': lat, 'lon': lon};
  }
}
