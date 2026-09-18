/// An employee that exists in HRMS (created there directly, e.g. via the
/// biometric device admin) but has no linked record in this app yet.
class HrmsUnlinkedEmployee {
  final int id;
  final String employeeCode;
  final String deviceUserId;
  final String name;
  final String? designation;
  final String? departmentName;

  const HrmsUnlinkedEmployee({
    required this.id,
    required this.employeeCode,
    required this.deviceUserId,
    required this.name,
    this.designation,
    this.departmentName,
  });

  factory HrmsUnlinkedEmployee.fromJson(Map<String, dynamic> json) {
    return HrmsUnlinkedEmployee(
      id: json['id'] as int,
      employeeCode: json['employee_code'] as String,
      deviceUserId: json['device_user_id'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String?,
      departmentName: json['department_name'] as String?,
    );
  }
}
