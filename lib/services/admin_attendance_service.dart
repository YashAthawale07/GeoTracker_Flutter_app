import '../core/constants.dart';
import '../models/attendance_history_record.dart';
import 'api_helper.dart';

class AdminAttendanceService {
  static Future<List<AttendanceHistoryRecord>> getEmployeeHistory({
    required String empId,
  }) async {
    final uri = Uri.parse("${Constants.baseUrl}/admin/attendance/$empId");
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getEmployeeHistoryByMonth({
    required String empId,
    required int month,
    required int year,
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/$empId/month").replace(
      queryParameters: {
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

  static Future<List<AttendanceHistoryRecord>> getEmployeeHistoryByRange({
    required String empId,
    required String startDate, // yyyy-MM-dd
    required String endDate, // yyyy-MM-dd
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/$empId/range").replace(
      queryParameters: {
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

  static Future<List<AttendanceHistoryRecord>> getEmployeeHistoryByStatus({
    required String empId,
    required String status,
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/$empId/status").replace(
      queryParameters: {'status': status},
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getAllEmployeesHistory() async {
    final uri = Uri.parse("${Constants.baseUrl}/admin/attendance");
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>> getAllEmployeesHistoryByMonth({
    required int month,
    required int year,
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/all/month").replace(
      queryParameters: {
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

  static Future<List<AttendanceHistoryRecord>> getAllEmployeesHistoryByRange({
    required String startDate, // yyyy-MM-dd
    required String endDate, // yyyy-MM-dd
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/all/range").replace(
      queryParameters: {
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

  static Future<List<AttendanceHistoryRecord>> getAllEmployeesHistoryByStatus({
    required String status,
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/all/status").replace(
      queryParameters: {'status': status},
    );
    final res = await ApiHelper.get(uri.toString());
    final list = res as List;
    return list
        .map((e) => AttendanceHistoryRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AttendanceHistoryRecord>>
      getAllEmployeesHistoryByStatusAndRange({
    required String status,
    required String startDate, // yyyy-MM-dd
    required String endDate, // yyyy-MM-dd
  }) async {
    final uri =
        Uri.parse("${Constants.baseUrl}/admin/attendance/all/filter").replace(
      queryParameters: {
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

