/// One synced day of attendance for one employee, pulled from our own
/// /api/attendance/history endpoint (backed by the local attendance_records
/// table) rather than HRMS's live "today only" view.
class AttendanceHistoryRecord {
  final int id;
  final String employeeName;
  final String employeeCode;
  final String? departmentName;
  final DateTime workDate;
  final String? firstIn;
  final String? lastOut;
  final double? totalHours;
  final String? status;
  final bool late;

  const AttendanceHistoryRecord({
    required this.id,
    required this.employeeName,
    required this.employeeCode,
    this.departmentName,
    required this.workDate,
    this.firstIn,
    this.lastOut,
    this.totalHours,
    this.status,
    required this.late,
  });

  factory AttendanceHistoryRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryRecord(
      id: (json['id'] as num).toInt(),
      employeeName: json['employeeName'] as String,
      employeeCode: json['employeeCode'] as String,
      departmentName: json['departmentName'] as String?,
      workDate: DateTime.parse(json['workDate'] as String),
      firstIn: json['firstIn'] as String?,
      lastOut: json['lastOut'] as String?,
      totalHours: (json['totalHours'] as num?)?.toDouble(),
      status: json['status'] as String?,
      late: json['late'] as bool? ?? false,
    );
  }
}

class AttendanceSyncResult {
  final DateTime from;
  final DateTime to;
  final int daysProcessed;
  final int recordsSynced;
  final int recordsUnmatched;

  const AttendanceSyncResult({
    required this.from,
    required this.to,
    required this.daysProcessed,
    required this.recordsSynced,
    required this.recordsUnmatched,
  });

  factory AttendanceSyncResult.fromJson(Map<String, dynamic> json) {
    return AttendanceSyncResult(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      daysProcessed: (json['daysProcessed'] as num).toInt(),
      recordsSynced: (json['recordsSynced'] as num).toInt(),
      recordsUnmatched: (json['recordsUnmatched'] as num).toInt(),
    );
  }
}
