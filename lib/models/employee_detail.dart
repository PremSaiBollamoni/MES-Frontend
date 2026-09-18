class EmployeeDetail {
  final int id;
  final String employeeCode;
  final String name;
  final String username;
  final String roleCode;
  final List<String> roleCodes;
  final bool active;
  final String? department;
  final String? designation;
  final DateTime? dateOfJoining;
  final String? shift;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? emergencyContactRelationship;
  final String? bankName;
  final String? bankAccountNumber;
  final String? ifscCode;
  final DateTime? createdAt;
  final int? hrmsEmployeeId;
  final String? hrmsEmployeeCode;
  final String? hrmsDeviceUserId;
  final String hrmsSyncStatus;

  const EmployeeDetail({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.username,
    required this.roleCode,
    this.roleCodes = const [],
    required this.active,
    this.department,
    this.designation,
    this.dateOfJoining,
    this.shift,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.emergencyContactRelationship,
    this.bankName,
    this.bankAccountNumber,
    this.ifscCode,
    this.createdAt,
    this.hrmsEmployeeId,
    this.hrmsEmployeeCode,
    this.hrmsDeviceUserId,
    this.hrmsSyncStatus = 'NOT_SYNCED',
  });

  bool get isSyncedToHrms => hrmsSyncStatus == 'SYNCED' && hrmsEmployeeId != null;

  factory EmployeeDetail.fromJson(Map<String, dynamic> json) {
    return EmployeeDetail(
      id: json['id'] as int,
      employeeCode: json['employeeCode'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      roleCode: json['roleCode'] as String,
      roleCodes: (json['roleCodes'] as List<dynamic>? ?? []).cast<String>(),
      active: json['active'] as bool,
      department: json['department'] as String?,
      designation: json['designation'] as String?,
      dateOfJoining: json['dateOfJoining'] != null ? DateTime.parse(json['dateOfJoining'] as String) : null,
      shift: json['shift'] as String?,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth'] as String) : null,
      gender: json['gender'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      address: json['address'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactNumber: json['emergencyContactNumber'] as String?,
      emergencyContactRelationship: json['emergencyContactRelationship'] as String?,
      bankName: json['bankName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      hrmsEmployeeId: json['hrmsEmployeeId'] as int?,
      hrmsEmployeeCode: json['hrmsEmployeeCode'] as String?,
      hrmsDeviceUserId: json['hrmsDeviceUserId'] as String?,
      hrmsSyncStatus: json['hrmsSyncStatus'] as String? ?? 'NOT_SYNCED',
    );
  }
}
