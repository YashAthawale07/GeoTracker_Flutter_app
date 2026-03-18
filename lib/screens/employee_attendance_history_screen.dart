import 'package:flutter/material.dart';

import '../core/session.dart';
import '../models/attendance_history_record.dart';
import '../services/attendance_service.dart';

enum AttendanceFilterType { all, month, range, status, statusRange }

class EmployeeAttendanceHistoryScreen extends StatefulWidget {
  const EmployeeAttendanceHistoryScreen({super.key});

  @override
  State<EmployeeAttendanceHistoryScreen> createState() =>
      _EmployeeAttendanceHistoryScreenState();
}

class _EmployeeAttendanceHistoryScreenState
    extends State<EmployeeAttendanceHistoryScreen> {
  AttendanceFilterType _filterType = AttendanceFilterType.all;
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

  Future<void> _fetch() async {
    final empId = Session.empId;
    if (empId == null || empId.trim().isEmpty) {
      setState(() {
        _error = "Employee ID not found. Please login again.";
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
      List<AttendanceHistoryRecord> items;
      switch (_filterType) {
        case AttendanceFilterType.all:
          items = await AttendanceService.getHistory(empId: empId.trim());
          break;
        case AttendanceFilterType.month:
          items = await AttendanceService.getHistoryByMonth(
            empId: empId.trim(),
            month: _month,
            year: _year,
          );
          break;
        case AttendanceFilterType.range:
          if (_startDate == null || _endDate == null) {
            throw Exception("Please select start and end dates.");
          }
          items = await AttendanceService.getHistoryByRange(
            empId: empId.trim(),
            startDate: _fmtDate(_startDate!),
            endDate: _fmtDate(_endDate!),
          );
          break;
        case AttendanceFilterType.status:
          items = await AttendanceService.getHistoryByStatus(
            empId: empId.trim(),
            status: _status,
          );
          break;
        case AttendanceFilterType.statusRange:
          if (_startDate == null || _endDate == null) {
            throw Exception("Please select start and end dates.");
          }
          items = await AttendanceService.getHistoryByStatusAndRange(
            empId: empId.trim(),
            status: _status,
            startDate: _fmtDate(_startDate!),
            endDate: _fmtDate(_endDate!),
          );
          break;
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

  Widget _filterControls() {
    final years = List.generate(7, (i) => DateTime.now().year - 5 + i);
    return Column(
      children: [
        DropdownButtonFormField<AttendanceFilterType>(
          initialValue: _filterType,
          decoration: const InputDecoration(
            labelText: 'Filter',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: AttendanceFilterType.all,
              child: Text('Full history'),
            ),
            DropdownMenuItem(
              value: AttendanceFilterType.month,
              child: Text('By month'),
            ),
            DropdownMenuItem(
              value: AttendanceFilterType.range,
              child: Text('By date range'),
            ),
            DropdownMenuItem(
              value: AttendanceFilterType.status,
              child: Text('By status'),
            ),
            DropdownMenuItem(
              value: AttendanceFilterType.statusRange,
              child: Text('By status + date range'),
            ),
          ],
          onChanged: (val) {
            if (val == null) return;
            setState(() => _filterType = val);
          },
        ),
        const SizedBox(height: 12),
        if (_filterType == AttendanceFilterType.month) ...[
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
        if (_filterType == AttendanceFilterType.status ||
            _filterType == AttendanceFilterType.statusRange) ...[
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
        if (_filterType == AttendanceFilterType.range ||
            _filterType == AttendanceFilterType.statusRange) ...[
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
        title: const Text('Attendance History'),
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
            _filterControls(),
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
                                if (item.time.isNotEmpty) {
                                  subtitleParts.add(item.time);
                                }
                                if (item.date.isNotEmpty) {
                                  subtitleParts.add(item.date);
                                }
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

