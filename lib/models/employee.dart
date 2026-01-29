class Employee {
  final String empId;
  final String name;

  Employee({required this.empId, required this.name});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(empId: json['empId'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'empId': empId, 'name': name};
  }
}
