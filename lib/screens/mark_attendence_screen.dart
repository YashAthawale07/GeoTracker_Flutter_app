import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/attendance_service.dart';
import '../core/session.dart';
import '../widgets/custom_button.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Request location permission
  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Location permissions are permanently denied. Enable them from settings.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markAttendance() async {
    final empId = Session.empId;

    if (empId == null) {
      _showSnackBar("Employee ID not found. Please login again.");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      double latitude;
      double longitude;

      // ====== Option 1: Hardcoded lat/long ======
      // Uncomment these to use hardcoded location instead of device geolocation
      // latitude = 21.0077;
      // longitude = 75.5626;

      // ====== Option 2: Get from Geolocation ======
      // Comment out the below lines if using hardcoded lat/long
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;

      // Call attendance API
      final message = await AttendanceService.markAttendance(empId, latitude, longitude);

      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mark Attendance")),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : CustomButton(
                text: "Mark Attendance",
                onPressed: _markAttendance,
              ),
      ),
    );
  }
}
