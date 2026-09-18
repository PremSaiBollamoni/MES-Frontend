class EmployeeSummary {
  final int id;
  final String? employeeCode;
  final String name;
  final String username;
  final String roleCode;
  final List<String> roleCodes;
  final String? department;
  final String? designation;
  final String? shift;
  final bool active;

  const EmployeeSummary({
    required this.id,
    this.employeeCode,
    required this.name,
    required this.username,
    required this.roleCode,
    this.roleCodes = const [],
    this.department,
    this.designation,
    this.shift,
    required this.active,
  });

  bool get hasMultipleRoles => roleCodes.length > 1;

  factory EmployeeSummary.fromJson(Map<String, dynamic> json) {
    return EmployeeSummary(
      id: json['id'] as int,
      employeeCode: json['employeeCode'] as String?,
      name: json['name'] as String,
      username: json['username'] as String,
      roleCode: json['roleCode'] as String,
      roleCodes: (json['roleCodes'] as List<dynamic>? ?? []).cast<String>(),
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      shift: json['shift'] as String?,
      active: json['active'] as bool,
    );
  }
}
