import 'package:flutter/material.dart';
import 'package:geotracker_flutter/screens/mark_attendence_screen.dart';
// import 'mark_attendance_screen.dart';
import '../core/session.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Home"),
        actions: [
          IconButton(
              onPressed: () {
                Session.clear();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: "Mark Attendance",
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => MarkAttendanceScreen()));
          },
        ),
      ),
    );
  }
}
