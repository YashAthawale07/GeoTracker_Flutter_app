import 'package:flutter/material.dart';
import '../services/employee_service.dart';
import '../models/employee.dart';
import '../widgets/employee_tile.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> employees = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final list = await EmployeeService.getAllEmployees();
      setState(() {
        employees = list;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void deleteEmployee(String empId) async {
    bool success = await EmployeeService.deleteEmployee(empId);
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Employee deleted")));
      fetchEmployees();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to delete employee")));
    }
  }

  void editEmployee(Employee employee) async {
    TextEditingController nameController =
        TextEditingController(text: employee.name);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Employee"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              String newName = nameController.text.trim();
              if (newName.isEmpty) return;

              try {
                // Updated service now returns Employee object
                Employee updated =
                    await EmployeeService.updateEmployee(employee.empId, newName);

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Employee updated")));
                Navigator.pop(context);
                fetchEmployees(); // Refresh the list
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update employee: $e")));
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Employee List")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : employees.isEmpty
                  ? const Center(child: Text("No employees found"))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: employees.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, index) => EmployeeTile(
                        employee: employees[index],
                        onEdit: () => editEmployee(employees[index]),
                        onDelete: () =>
                            deleteEmployee(employees[index].empId),
                      ),
                    ),
    );
  }
}
