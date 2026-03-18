class Employee {
  final String empId;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String role;
  final String post;

  Employee({
    required this.empId,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.role,
    required this.post,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: (json['empId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      post: (json['post'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'role': role,
      'post': post,
    };
  }
}
