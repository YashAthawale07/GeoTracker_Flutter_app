import 'package:flutter/material.dart';
import 'add_employee_screen.dart';
import 'employee_list_screen.dart';
import '../core/session.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Home"),
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
        child: Column(
          children: [
            CustomButton(
              text: "Add Employee",
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddEmployeeScreen()));
              },
            ),
            SizedBox(height: 10),
            CustomButton(
              text: "Employee List",
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => EmployeeListScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
