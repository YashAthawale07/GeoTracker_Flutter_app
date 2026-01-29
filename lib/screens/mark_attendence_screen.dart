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
  double? latitude;
  double? longitude;

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
      _showSnackBar(
          "Location permissions are permanently denied. Enable them from settings.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      // ====== Option 1: Hardcoded lat/long ======
      // Uncomment these lines to use hardcoded coordinates
      // latitude = 21.0077;
      // longitude = 75.5626;

      // ====== Option 2: Use Geolocation ======
      // Comment the below if using hardcoded coordinates
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;

      // Call API
      final message =
          await AttendanceService.markAttendance(empId, latitude!, longitude!);

      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent, size: 30),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final empId = Session.empId ?? "Not logged in";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mark Attendance"),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Heading
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Attendance Dashboard",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 10),

              // Employee Info Card
              _buildInfoCard("Employee ID", empId, Icons.person),

              // Location Info Card (if available)
              _buildInfoCard(
                  "Location",
                  latitude != null && longitude != null
                      ? "Lat: ${latitude!.toStringAsFixed(4)}, Lon: ${longitude!.toStringAsFixed(4)}"
                      : "Not fetched yet",
                  Icons.location_on),

              const SizedBox(height: 20),

              // Mark Attendance Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: "Mark Attendance",
                        onPressed: _markAttendance,
                      ),
              ),

              const SizedBox(height: 30),

              // Additional Info
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Note: Attendance will be marked based on your current location. "
                  "You can use hardcoded location by enabling it in the code.",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
