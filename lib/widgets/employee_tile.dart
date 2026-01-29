import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeTile extends StatelessWidget {
  final Employee employee;

  const EmployeeTile({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(employee.name),
      subtitle: Text(employee.empId),
    );
  }
}
