import 'package:flutter/material.dart';
import '../core/session.dart';
import 'admin_home.dart';
import 'employee_home.dart';
import '../widgets/custom_button.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // temporary frontend validation
      if (username == 'admin' && password == 'admin123') {
        Session.userRole = 'admin';
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminHome()));
      } else if (username.startsWith('EMP001') && password == 'emp123') {
        Session.userRole = 'employee';
        Session.empId = username;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => EmployeeHome()));
      }else if (username.startsWith('EMP002') && password == 'emp123') {
        Session.userRole = 'employee';
        Session.empId = username;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => EmployeeHome()));
      }  
      else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid credentials")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: Validators.validateNotEmpty,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: Validators.validateNotEmpty,
              ),
              SizedBox(height: 20),
              CustomButton(text: "Login", onPressed: login),
            ],
          ),
        ),
      ),
    );
  }
}
