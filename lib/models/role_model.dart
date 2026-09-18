import '../utils/role_display.dart';

class RoleModel {
  final String roleCode;

  const RoleModel({required this.roleCode});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleCode: json['roleCode'] as String,
    );
  }

  String get displayName => RoleDisplay.name(roleCode);
}
