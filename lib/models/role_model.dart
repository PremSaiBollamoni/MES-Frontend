class RoleModel {
  final String roleCode;

  const RoleModel({required this.roleCode});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleCode: json['roleCode'] as String,
    );
  }

  String get displayName {
    return roleCode
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0] + word.substring(1).toLowerCase())
        .join(' ');
  }
}
