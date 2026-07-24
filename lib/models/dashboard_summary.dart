class RecentJoiner {
  final String name;
  final String employeeCode;
  final String? department;
  final DateTime dateOfJoining;

  const RecentJoiner({
    required this.name,
    required this.employeeCode,
    this.department,
    required this.dateOfJoining,
  });

  factory RecentJoiner.fromJson(Map<String, dynamic> json) {
    return RecentJoiner(
      name: json['name'] as String,
      employeeCode: json['employeeCode'] as String,
      department: json['department'] as String?,
      dateOfJoining: DateTime.parse(json['dateOfJoining'] as String),
    );
  }
}

class DashboardSummary {
  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final Map<String, int> employeesByRole;
  final Map<String, int> employeesByDepartment;
  final List<RecentJoiner> recentJoiners;

  const DashboardSummary({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.employeesByRole,
    required this.employeesByDepartment,
    required this.recentJoiners,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseCounts(dynamic raw) {
      return (raw as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toInt()));
    }

    return DashboardSummary(
      totalEmployees: (json['totalEmployees'] as num).toInt(),
      activeEmployees: (json['activeEmployees'] as num).toInt(),
      inactiveEmployees: (json['inactiveEmployees'] as num).toInt(),
      employeesByRole: parseCounts(json['employeesByRole']),
      employeesByDepartment: parseCounts(json['employeesByDepartment']),
      recentJoiners: (json['recentJoiners'] as List<dynamic>)
          .map((e) => RecentJoiner.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
