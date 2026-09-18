class ProfileUpdateRequest {
  final String? name;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? emergencyContactRelationship;

  const ProfileUpdateRequest({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.address,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.emergencyContactRelationship,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String().split('T').first,
        if (gender != null) 'gender': gender,
        if (bloodGroup != null) 'bloodGroup': bloodGroup,
        if (address != null) 'address': address,
        if (emergencyContactName != null) 'emergencyContactName': emergencyContactName,
        if (emergencyContactNumber != null) 'emergencyContactNumber': emergencyContactNumber,
        if (emergencyContactRelationship != null) 'emergencyContactRelationship': emergencyContactRelationship,
      };
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({required this.currentPassword, required this.newPassword});

  Map<String, dynamic> toJson() => {'currentPassword': currentPassword, 'newPassword': newPassword};
}
