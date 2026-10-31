class FactoryKpiSummary {
  final int factoryId;
  final String factoryName;
  final String factoryCode;
  final bool active;
  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final int stationCount;
  final int todayProductionPieces;
  final int todayProductionEntries;
  final int todayAttendancePresent;
  final int todayAttendanceTotal;
  final double monthToDatePayroll;

  const FactoryKpiSummary({
    required this.factoryId,
    required this.factoryName,
    required this.factoryCode,
    required this.active,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.stationCount,
    required this.todayProductionPieces,
    required this.todayProductionEntries,
    required this.todayAttendancePresent,
    required this.todayAttendanceTotal,
    required this.monthToDatePayroll,
  });

  double get attendanceRate => todayAttendanceTotal == 0 ? 0 : todayAttendancePresent / todayAttendanceTotal;

  factory FactoryKpiSummary.fromJson(Map<String, dynamic> json) {
    return FactoryKpiSummary(
      factoryId: json['factoryId'] as int,
      factoryName: json['factoryName'] as String,
      factoryCode: json['factoryCode'] as String,
      active: json['active'] as bool? ?? true,
      totalEmployees: json['totalEmployees'] as int? ?? 0,
      activeEmployees: json['activeEmployees'] as int? ?? 0,
      inactiveEmployees: json['inactiveEmployees'] as int? ?? 0,
      stationCount: json['stationCount'] as int? ?? 0,
      todayProductionPieces: json['todayProductionPieces'] as int? ?? 0,
      todayProductionEntries: json['todayProductionEntries'] as int? ?? 0,
      todayAttendancePresent: json['todayAttendancePresent'] as int? ?? 0,
      todayAttendanceTotal: json['todayAttendanceTotal'] as int? ?? 0,
      monthToDatePayroll: (json['monthToDatePayroll'] as num?)?.toDouble() ?? 0,
    );
  }
}
