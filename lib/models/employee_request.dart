/// Payload for creating a new employee. Mirrors the backend's EmployeeCreateRequest.
/// Username is system-generated (MES001, MES002, ...) and not supplied here.
/// [password] is optional - if omitted, the backend assigns the default password.
class EmployeeCreateRequest {
  final String? password;
  final String name;
  final String roleCode;
  final String employeeCode;
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

  const EmployeeCreateRequest({
    this.password,
    required this.name,
    required this.roleCode,
    required this.employeeCode,
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
  });

  Map<String, dynamic> toJson() => {
        if (password != null && password!.isNotEmpty) 'password': password,
        'name': name,
        'roleCode': roleCode,
        'employeeCode': employeeCode,
        'department': department,
        'designation': designation,
        'dateOfJoining': dateOfJoining?.toIso8601String().split('T').first,
        'shift': shift,
        'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'address': address,
        'emergencyContactName': emergencyContactName,
        'emergencyContactNumber': emergencyContactNumber,
        'emergencyContactRelationship': emergencyContactRelationship,
        'bankName': bankName,
        'bankAccountNumber': bankAccountNumber,
        'ifscCode': ifscCode,
      };
}

/// Payload for updating an employee. All fields optional - only non-null values
/// are sent, mirroring the backend's partial-update EmployeeUpdateRequest.
/// Username is system-generated and not editable here.
class EmployeeUpdateRequest {
  final String? password;
  final String? name;
  final String? roleCode;
  final bool? active;
  final String? employeeCode;
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

  const EmployeeUpdateRequest({
    this.password,
    this.name,
    this.roleCode,
    this.active,
    this.employeeCode,
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
  });

  Map<String, dynamic> toJson() => {
        if (password != null && password!.isNotEmpty) 'password': password,
        if (name != null) 'name': name,
        if (roleCode != null) 'roleCode': roleCode,
        if (active != null) 'active': active,
        if (employeeCode != null) 'employeeCode': employeeCode,
        if (department != null) 'department': department,
        if (designation != null) 'designation': designation,
        if (dateOfJoining != null) 'dateOfJoining': dateOfJoining!.toIso8601String().split('T').first,
        if (shift != null) 'shift': shift,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String().split('T').first,
        if (gender != null) 'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (address != null) 'address': address,
        if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
        if (emergencyContactNumber != null) 'emergencyContactNumber': emergencyContactNumber,
        if (emergencyContactRelationship != null) 'emergencyContactRelationship': emergencyContactRelationship,
        if (bankName != null) 'bankName': bankName,
        if (bankAccountNumber != null) 'bankAccountNumber': bankAccountNumber,
        if (ifscCode != null) 'ifscCode': ifscCode,
      };
}
