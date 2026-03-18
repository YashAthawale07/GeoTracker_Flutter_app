import 'package:flutter/material.dart';

import '../models/attendance_history_record.dart';
import '../services/admin_attendance_service.dart';

enum AdminAttendanceScope { allEmployees, oneEmployee }
enum AdminAttendanceFilter { full, month, range, status, statusRange }

class AdminAttendanceHistoryScreen extends StatefulWidget {
  const AdminAttendanceHistoryScreen({super.key});

  @override
  State<AdminAttendanceHistoryScreen> createState() =>
      _AdminAttendanceHistoryScreenState();
}

class _AdminAttendanceHistoryScreenState
    extends State<AdminAttendanceHistoryScreen> {
  AdminAttendanceScope _scope = AdminAttendanceScope.allEmployees;
  AdminAttendanceFilter _filter = AdminAttendanceFilter.full;

  final _empIdController = TextEditingController();
  String _status = 'PRESENT';
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _loading = false;
  String? _error;
  List<AttendanceHistoryRecord> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _empIdController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "${d.year}-$mm-$dd";
  }

  Future<void> _pickStartDate() async {
    final initial = _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      if (_endDate != null && _endDate!.isBefore(picked)) {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final initial = _endDate ?? _startDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      if (_startDate != null && picked.isBefore(_startDate!)) {
        _startDate = picked;
      }
    });
  }

  String? _validateInputs() {
    if (_scope == AdminAttendanceScope.oneEmployee) {
      final empId = _empIdController.text.trim();
      if (empId.isEmpty) return "Please enter Employee ID (e.g. EMP101).";
    }
    if (_filter == AdminAttendanceFilter.range ||
        _filter == AdminAttendanceFilter.statusRange) {
      if (_startDate == null || _endDate == null) {
        return "Please select start and end dates.";
      }
    }
    return null;
  }

  Future<void> _fetch() async {
    final validationError = _validateInputs();
    if (validationError != null) {
      setState(() {
        _error = validationError;
        _items = [];
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final empId = _empIdController.text.trim();
      List<AttendanceHistoryRecord> items;

      if (_scope == AdminAttendanceScope.oneEmployee) {
        switch (_filter) {
          case AdminAttendanceFilter.full:
            items = await AdminAttendanceService.getEmployeeHistory(empId: empId);
            break;
          case AdminAttendanceFilter.month:
            items = await AdminAttendanceService.getEmployeeHistoryByMonth(
              empId: empId,
              month: _month,
              year: _year,
            );
            break;
          case AdminAttendanceFilter.range:
            items = await AdminAttendanceService.getEmployeeHistoryByRange(
              empId: empId,
              startDate: _fmtDate(_startDate!),
              endDate: _fmtDate(_endDate!),
            );
            break;
          case AdminAttendanceFilter.status:
            items = await AdminAttendanceService.getEmployeeHistoryByStatus(
              empId: empId,
              status: _status,
            );
            break;
          case AdminAttendanceFilter.statusRange:
            // No explicit backend endpoint provided for employee status+range.
            // Fall back to range and filter client-side.
            final ranged = await AdminAttendanceService.getEmployeeHistoryByRange(
              empId: empId,
              startDate: _fmtDate(_startDate!),
              endDate: _fmtDate(_endDate!),
            );
            items = ranged
                .where((r) => r.status.toUpperCase() == _status.toUpperCase())
                .toList();
            break;
        }
      } else {
        switch (_filter) {
          case AdminAttendanceFilter.full:
            items = await AdminAttendanceService.getAllEmployeesHistory();
            break;
          case AdminAttendanceFilter.month:
            items = await AdminAttendanceService.getAllEmployeesHistoryByMonth(
              month: _month,
              year: _year,
            );
            break;
          case AdminAttendanceFilter.range:
            items = await AdminAttendanceService.getAllEmployeesHistoryByRange(
              startDate: _fmtDate(_startDate!),
              endDate: _fmtDate(_endDate!),
            );
            break;
          case AdminAttendanceFilter.status:
            items = await AdminAttendanceService.getAllEmployeesHistoryByStatus(
              status: _status,
            );
            break;
          case AdminAttendanceFilter.statusRange:
            items = await AdminAttendanceService.getAllEmployeesHistoryByStatusAndRange(
              status: _status,
              startDate: _fmtDate(_startDate!),
              endDate: _fmtDate(_endDate!),
            );
            break;
        }
      }

      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _items = [];
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return Colors.green;
      case 'LATE':
        return Colors.orange;
      case 'ABSENT':
        return Colors.redAccent;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _controls() {
    final years = List.generate(7, (i) => DateTime.now().year - 5 + i);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<AdminAttendanceScope>(
                initialValue: _scope,
                decoration: const InputDecoration(
                  labelText: 'Scope',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AdminAttendanceScope.allEmployees,
                    child: Text('All employees'),
                  ),
                  DropdownMenuItem(
                    value: AdminAttendanceScope.oneEmployee,
                    child: Text('One employee'),
                  ),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _scope = val);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<AdminAttendanceFilter>(
                initialValue: _filter,
                decoration: const InputDecoration(
                  labelText: 'Filter',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AdminAttendanceFilter.full,
                    child: Text('Full history'),
                  ),
                  DropdownMenuItem(
                    value: AdminAttendanceFilter.month,
                    child: Text('By month'),
                  ),
                  DropdownMenuItem(
                    value: AdminAttendanceFilter.range,
                    child: Text('By date range'),
                  ),
                  DropdownMenuItem(
                    value: AdminAttendanceFilter.status,
                    child: Text('By status'),
                  ),
                  DropdownMenuItem(
                    value: AdminAttendanceFilter.statusRange,
                    child: Text('Status + date range'),
                  ),
                ],
                onChanged: (val) {
                  if (val == null) return;
                  setState(() => _filter = val);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_scope == AdminAttendanceScope.oneEmployee) ...[
          TextField(
            controller: _empIdController,
            decoration: const InputDecoration(
              labelText: 'Employee ID (e.g. EMP101)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_filter == AdminAttendanceFilter.month) ...[
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _month,
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text((i + 1).toString()),
                    ),
                  ),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _month = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _year,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(),
                  ),
                  items: years
                      .map((y) =>
                          DropdownMenuItem(value: y, child: Text("$y")))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _year = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (_filter == AdminAttendanceFilter.status ||
            _filter == AdminAttendanceFilter.statusRange) ...[
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'PRESENT', child: Text('PRESENT')),
              DropdownMenuItem(value: 'LATE', child: Text('LATE')),
              DropdownMenuItem(value: 'ABSENT', child: Text('ABSENT')),
            ],
            onChanged: (val) {
              if (val == null) return;
              setState(() => _status = val);
            },
          ),
          const SizedBox(height: 12),
        ],
        if (_filter == AdminAttendanceFilter.range ||
            _filter == AdminAttendanceFilter.statusRange) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate == null ? "Start date" : _fmtDate(_startDate!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: const Icon(Icons.event),
                  label: Text(
                    _endDate == null ? "End date" : _fmtDate(_endDate!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.search),
            label: const Text('Apply'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Employees Attendance History'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _controls(),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _items.isEmpty
                          ? const Center(child: Text('No records found'))
                          : ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                final status = item.status;
                                final subtitleParts = <String>[];
                                if (_scope == AdminAttendanceScope.allEmployees) {
                                  final empId =
                                      (item.raw['empId'] ?? '').toString();
                                  if (empId.isNotEmpty) subtitleParts.add(empId);
                                }
                                if (item.time.isNotEmpty) subtitleParts.add(item.time);
                                if (item.date.isNotEmpty) subtitleParts.add(item.date);
                                if (item.locationText.isNotEmpty) {
                                  subtitleParts.add(item.locationText);
                                }

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _statusColor(status).withValues(
                                        alpha: 0.15,
                                      ),
                                      child: Icon(
                                        Icons.check_circle_outline,
                                        color: _statusColor(status),
                                      ),
                                    ),
                                    title: Text(
                                      status.isEmpty ? 'UNKNOWN' : status,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      subtitleParts.isEmpty
                                          ? item.raw.toString()
                                          : subtitleParts.join(' • '),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

