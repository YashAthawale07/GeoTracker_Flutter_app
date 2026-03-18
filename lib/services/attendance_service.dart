import 'package:geotracker_flutter/services/api_helper.dart';

import '../core/constants.dart';
import '../models/attendance_history_record.dart';
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

  static Future<List<AttendanceHistoryRecord>> getHistory({
    required String empId,
  }) async {
    final uri = Uri.parse("${Constants.baseUrl}/attendance/history").replace(
      queryParameters: {'empId': empId},
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getHistoryByMonth({
    required String empId,
    required int month,
    required int year,
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/attendance/history/month").replace(
      queryParameters: {
        'empId': empId,
        'month': month.toString(),
        'year': year.toString(),
      },
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getHistoryByRange({
    required String empId,
    required String startDate, // yyyy-MM-dd
    required String endDate, // yyyy-MM-dd
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/attendance/history/range").replace(
      queryParameters: {
        'empId': empId,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getHistoryByStatus({
    required String empId,
    required String status,
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/attendance/history/status").replace(
      queryParameters: {
        'empId': empId,
        'status': status,
      },
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getHistoryByStatusAndRange({
    required String empId,
    required String status,
    required String startDate, // yyyy-MM-dd
    required String endDate, // yyyy-MM-dd
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/attendance/history/filter").replace(
      queryParameters: {
        'empId': empId,
        'status': status,
        'startDate': startDate,
        'endDate': endDate,
      },
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
