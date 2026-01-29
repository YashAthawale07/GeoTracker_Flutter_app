import 'package:flutter/material.dart';
import '../services/employee_service.dart';
import '../models/employee.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empIdController = TextEditingController();
  final _nameController = TextEditingController();

  void addEmployee() async {
    if (_formKey.currentState!.validate()) {
      Employee emp = Employee(
          empId: _empIdController.text.trim(), name: _nameController.text.trim());
      bool success = await EmployeeService.addEmployee(emp);
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Employee added successfully")));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to add employee")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Employee")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _empIdController,
                decoration: InputDecoration(labelText: "Employee ID"),
                validator: Validators.validateNotEmpty,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: Validators.validateNotEmpty,
              ),
              SizedBox(height: 20),
              CustomButton(text: "Add Employee", onPressed: addEmployee),
            ],
          ),
        ),
      ),
    );
  }
}
