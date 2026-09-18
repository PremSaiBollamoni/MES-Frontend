class LiveAttendanceStatus {
  final List<Map<String, dynamic>> present;
  final List<Map<String, dynamic>> absent;
  final List<Map<String, dynamic>> late;
  final int totalEmployees;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final DateTime asOf;

  const LiveAttendanceStatus({
    required this.present,
    required this.absent,
    required this.late,
    required this.totalEmployees,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.asOf,
  });

  factory LiveAttendanceStatus.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> parseList(dynamic raw) {
      return (raw as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
    }

    return LiveAttendanceStatus(
      present: parseList(json['present']),
      absent: parseList(json['absent']),
      late: parseList(json['late']),
      totalEmployees: (json['total_employees'] as num).toInt(),
      presentCount: (json['present_count'] as num).toInt(),
      absentCount: (json['absent_count'] as num).toInt(),
      lateCount: (json['late_count'] as num).toInt(),
      asOf: DateTime.parse(json['as_of'] as String),
    );
  }
}

class DailyAttendanceRecord {
  final int id;
  final String employeeName;
  final String employeeCode;
  final String? departmentName;
  final DateTime attendanceDate;
  final DateTime? firstIn;
  final DateTime? lastOut;
  final double totalHours;
  final String status;
  final bool isLate;

  const DailyAttendanceRecord({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    this.departmentName,
    required this.attendanceDate,
    this.firstIn,
    this.lastOut,
    required this.totalHours,
    required this.status,
    required this.isLate,
  });

  factory DailyAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceRecord(
      id: (json['id'] as num).toInt(),
      employeeName: json['employee_name'] as String,
      employeeCode: json['employee_code'] as String,
      departmentName: json['department_name'] as String?,
      attendanceDate: DateTime.parse(json['attendance_date'] as String),
      firstIn: json['first_in'] != null ? DateTime.parse(json['first_in'] as String) : null,
      lastOut: json['last_out'] != null ? DateTime.parse(json['last_out'] as String) : null,
      totalHours: (json['total_hours'] as num).toDouble(),
      status: json['status'] as String,
      isLate: json['is_late'] as bool,
    );
  }
}
