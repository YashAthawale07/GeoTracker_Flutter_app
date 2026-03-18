import 'package:flutter/material.dart';

import '../core/session.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  bool _loading = true;
  String? _error;
  Employee? _employee;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final empId = Session.empId;
    if (empId == null || empId.trim().isEmpty) {
      setState(() {
        _loading = false;
        _error = "Employee ID not found. Please login again.";
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await EmployeeService.getEmployeeProfile(empId.trim());
      setState(() {
        _employee = profile;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2563EB)),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? "-" : value,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("My Profile"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 40, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : _employee == null
                  ? const Center(child: Text("Profile not available"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor:
                                        const Color(0xFFEFF6FF),
                                    child: Text(
                                      (_employee!.name.isNotEmpty
                                              ? _employee!.name[0]
                                              : 'E')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _employee!.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _employee!.empId,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _infoRow(
                            icon: Icons.email_outlined,
                            label: "Email",
                            value: _employee!.email,
                          ),
                          _infoRow(
                            icon: Icons.phone_outlined,
                            label: "Phone",
                            value: _employee!.phone,
                          ),
                          _infoRow(
                            icon: Icons.apartment_outlined,
                            label: "Department",
                            value: _employee!.department,
                          ),
                          _infoRow(
                            icon: Icons.badge_outlined,
                            label: "Role",
                            value: _employee!.role,
                          ),
                          _infoRow(
                            icon: Icons.work_outline,
                            label: "Post",
                            value: _employee!.post,
                          ),
                        ],
                      ),
                    ),
    );
  }
}

