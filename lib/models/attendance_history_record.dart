class AttendanceHistoryRecord {
  final Map<String, dynamic> raw;

  AttendanceHistoryRecord(this.raw);

  factory AttendanceHistoryRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryRecord(json);
  }

  String get status => (raw['status'] ?? raw['attendanceStatus'] ?? '').toString();

  /// Supports common date keys from typical APIs.
  String get date =>
      (raw['date'] ?? raw['attendanceDate'] ?? raw['createdAt'] ?? raw['timestamp'] ?? '')
          .toString();

  String get time =>
      (raw['time'] ?? raw['attendanceTime'] ?? raw['checkInTime'] ?? '').toString();

  double? get latitude {
    final v = raw['latitude'] ?? raw['lat'];
    return v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
  }

  double? get longitude {
    final v = raw['longitude'] ?? raw['lon'] ?? raw['lng'];
    return v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
  }

  String get locationText {
    final lat = latitude;
    final lon = longitude;
    if (lat == null || lon == null) return '';
    return 'Lat: ${lat.toStringAsFixed(5)}, Lon: ${lon.toStringAsFixed(5)}';
  }
}

