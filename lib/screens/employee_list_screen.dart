import 'package:flutter/material.dart';
import '../services/employee_service.dart';
import '../models/employee.dart';
import '../widgets/employee_tile.dart';
import '../utils/validators.dart';

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
    if (!mounted) return;
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
    final nameController = TextEditingController(text: employee.name);
    final emailController = TextEditingController(text: employee.email);
    final phoneController = TextEditingController(text: employee.phone);
    final departmentController = TextEditingController(text: employee.department);
    final postController = TextEditingController(text: employee.post);
    String role = employee.role.isNotEmpty ? employee.role : 'EMPLOYEE';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Employee"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: Validators.validateNotEmpty,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: "Department"),
                  validator: Validators.validateNotEmpty,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: "Role"),
                  items: const [
                    DropdownMenuItem(value: 'EMPLOYEE', child: Text('EMPLOYEE')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    role = val;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: postController,
                  decoration: const InputDecoration(labelText: "Post"),
                  validator: Validators.validateNotEmpty,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final updatedEmp = Employee(
                empId: employee.empId,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                department: departmentController.text.trim(),
                role: role,
                post: postController.text.trim(),
              );

              try {
                // Updated service now returns Employee object
                await EmployeeService.updateEmployee(updatedEmp);
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Employee updated")));
                Navigator.pop(context);
                fetchEmployees(); // Refresh the list
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update employee: $e")));
              } finally {
                nameController.dispose();
                emailController.dispose();
                phoneController.dispose();
                departmentController.dispose();
                postController.dispose();
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
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
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
