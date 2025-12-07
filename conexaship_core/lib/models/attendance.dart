class Attendance {
  final int? id;
  final int employeeId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String? location;
  final String? ipAddress;
  final String? notes;
  final double? hoursWorked;
  final String status; // present, late, absent, half-day
  final DateTime? createdAt;

  Attendance({
    this.id,
    required this.employeeId,
    required this.clockIn,
    this.clockOut,
    this.location,
    this.ipAddress,
    this.notes,
    this.hoursWorked,
    this.status = 'present',
    this.createdAt,
  });

  bool get isClockedOut => clockOut != null;

  Duration get duration {
    if (clockOut == null) {
      return DateTime.now().difference(clockIn);
    }
    return clockOut!.difference(clockIn);
  }

  double get calculatedHours => duration.inMinutes / 60.0;

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int?,
      employeeId: json['employee_id'] ?? json['employeeId'] ?? 0,
      clockIn:
          DateTime.parse(json['clock_in'] ?? json['clockIn'] ?? DateTime.now().toIso8601String()),
      clockOut: json['clock_out'] != null || json['clockOut'] != null
          ? DateTime.parse(json['clock_out'] ?? json['clockOut'])
          : null,
      location: json['location'],
      ipAddress: json['ip_address'] ?? json['ipAddress'],
      notes: json['notes'],
      hoursWorked: json['hours_worked'] != null ? (json['hours_worked'] as num).toDouble() : null,
      status: json['status'] ?? 'present',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'clock_in': clockIn.toIso8601String(),
      'clock_out': clockOut?.toIso8601String(),
      'location': location,
      'ip_address': ipAddress,
      'notes': notes,
      'hours_worked': hoursWorked ?? calculatedHours,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
