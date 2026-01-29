import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const GeoTrackerApp());
}

class GeoTrackerApp extends StatelessWidget {
  const GeoTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Geo Tracker App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
