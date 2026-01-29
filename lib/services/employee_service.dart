import '../core/constants.dart';
import '../models/employee.dart';
import 'api_helper.dart';

class EmployeeService {
  // Add employee
  static Future<bool> addEmployee(Employee emp) async {
    final res = await ApiHelper.post("${Constants.baseUrl}/employees", emp.toJson());
    // assuming backend returns { "success": true }
    return res['success'] ?? true;
  }

  // Get single employee by empId
  static Future<Employee?> getEmployee(String empId) async {
    final res = await ApiHelper.get("${Constants.baseUrl}/employees/$empId");
    return Employee.fromJson(res as Map<String, dynamic>);
  }

  // Get all employees
  static Future<List<Employee>> getAllEmployees() async {
    final response = await ApiHelper.get("${Constants.baseUrl}/employees");
    // response is already decoded JSON (List of Maps)
    final list = response as List;
    return list.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Delete employee by empId
  static Future<bool> deleteEmployee(String empId) async {
    final response = await ApiHelper.delete("${Constants.baseUrl}/employees/delete?empId=$empId");
    // backend returns plain string like "Employee deleted successfully"
    return response == "Employee deleted successfully";
  }

  // Update employee by empId
  static Future<Employee> updateEmployee(String empId, String name) async {
    final response = await ApiHelper.put(
      "${Constants.baseUrl}/employees/update?empId=$empId&name=$name",
      body: {"name": name},
    );
    // response is updated employee JSON
    return Employee.fromJson(response as Map<String, dynamic>);
  }
}
