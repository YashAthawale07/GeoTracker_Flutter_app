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
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _postController = TextEditingController();
  String _role = 'EMPLOYEE';
  bool loading = false;

  Future<void> addEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final emp = Employee(
      empId: _empIdController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      department: _departmentController.text.trim(),
      role: _role,
      post: _postController.text.trim(),
    );

    final success = await EmployeeService.addEmployee(emp);
    if (!mounted) return;

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Employee added successfully" : "Failed to add employee",
        ),
      ),
    );

    if (success) {
      _empIdController.clear();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _departmentController.clear();
      _postController.clear();
      setState(() => _role = 'EMPLOYEE');
    }
  }

  @override
  void dispose() {
    _empIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Add Employee"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Employee",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Enter employee details to add them to the system",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),

            // Card Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _empIdController,
                      decoration: _inputDecoration("Employee ID"),
                      validator: Validators.validateNotEmpty,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Employee Name"),
                      validator: Validators.validateNotEmpty,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration("Phone"),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _departmentController,
                      decoration: _inputDecoration("Department"),
                      validator: Validators.validateNotEmpty,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: _inputDecoration("Role"),
                      items: const [
                        DropdownMenuItem(
                          value: 'EMPLOYEE',
                          child: Text('EMPLOYEE'),
                        ),
                        DropdownMenuItem(
                          value: 'ADMIN',
                          child: Text('ADMIN'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _role = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _postController,
                      decoration: _inputDecoration("Post"),
                      validator: Validators.validateNotEmpty,
                    ),
                    const SizedBox(height: 24),

                    loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: "Add Employee",
                              onPressed: addEmployee,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }
}
