import 'package:geotracker_flutter/services/api_helper.dart';

import '../core/constants.dart';
// import '../utils/api_helper.dart';

class AttendanceService {
  static Future<String> markAttendance(String empId, double lat, double lon) async {
    final url = "${Constants.baseUrl}/attendance/mark?empId=$empId&lat=$lat&lon=$lon";
    final result = await ApiHelper.post(url, {});
    
    if (result is String) {
      // Backend returned plain string
      return result;
    } else if (result is Map<String, dynamic>) {
      // Backend returned JSON
      return result['message'] ?? 'Attendance marked';
    } else {
      return 'Unknown response';
    }
  }
}
