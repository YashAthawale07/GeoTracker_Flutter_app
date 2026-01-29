import '../core/constants.dart';
import '../models/employee.dart';
import 'api_helper.dart';

class EmployeeService {
  static Future<bool> addEmployee(Employee emp) async {
    final res = await ApiHelper.post("${Constants.baseUrl}/employees", emp.toJson());
    return res['success'] ?? true; // assuming API returns {success:true}
  }

  static Future<Employee?> getEmployee(String empId) async {
    final res = await ApiHelper.get("${Constants.baseUrl}/employees/$empId");
    return Employee.fromJson(res);
  }

  static Future<List<Employee>> getAllEmployees() async {
    // assuming API exists: GET /employees
    final res = await ApiHelper.get("${Constants.baseUrl}/employees");
    List<Employee> list = (res as List).map((e) => Employee.fromJson(e)).toList();
    return list;
  }
}
