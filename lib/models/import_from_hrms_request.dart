class ImportFromHrmsRequest {
  final int hrmsEmployeeId;
  final String hrmsEmployeeCode;
  final String hrmsDeviceUserId;
  final String name;
  final String? designation;
  final String? department;
  final String roleCode;
  final String employeeCode;

  const ImportFromHrmsRequest({
    required this.hrmsEmployeeId,
    required this.hrmsEmployeeCode,
    required this.hrmsDeviceUserId,
    required this.name,
    this.designation,
    this.department,
    required this.roleCode,
    required this.employeeCode,
  });

  Map<String, dynamic> toJson() => {
        'hrmsEmployeeId': hrmsEmployeeId,
        'hrmsEmployeeCode': hrmsEmployeeCode,
        'hrmsDeviceUserId': hrmsDeviceUserId,
        'name': name,
        'designation': designation,
        'department': department,
        'roleCode': roleCode,
        'employeeCode': employeeCode,
      };
}
