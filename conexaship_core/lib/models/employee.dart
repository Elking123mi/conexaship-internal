class Employee {
  final int? id;
  final String employeeCode;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String department;
  final String position;
  final double? salary;
  final DateTime hireDate;
  final bool isActive;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Employee({
    this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.department,
    required this.position,
    this.salary,
    required this.hireDate,
    this.isActive = true,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int?,
      employeeCode: json['employee_code'] ?? json['employeeCode'] ?? json['username'] ?? '',
      firstName: json['first_name'] ??
          json['firstName'] ??
          json['full_name']?.toString().split(' ').first ??
          '',
      lastName: json['last_name'] ??
          json['lastName'] ??
          json['full_name']?.toString().split(' ').skip(1).join(' ') ??
          '',
      email: json['email'] ?? json['username'] ?? '',
      phone: json['phone'],
      department: json['department'] ?? 'General',
      position: json['position'] ?? json['roles']?.first ?? 'Employee',
      salary: json['salary'] != null ? (json['salary'] as num).toDouble() : null,
      hireDate: json['hire_date'] != null || json['hireDate'] != null
          ? DateTime.parse(json['hire_date'] ?? json['hireDate'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      isActive: json['is_active'] ?? json['isActive'] ?? json['status'] == 'active',
      photoUrl: json['photo_url'] ?? json['photoUrl'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_code': employeeCode,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'salary': salary,
      'hire_date': hireDate.toIso8601String(),
      'is_active': isActive,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
