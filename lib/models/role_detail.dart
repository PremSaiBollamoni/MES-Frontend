class RoleDetail {
  final int roleId;
  final String roleName;
  final List<String> activities;
  final String status;

  const RoleDetail({
    required this.roleId,
    required this.roleName,
    required this.activities,
    required this.status,
  });

  bool get isActive => status == 'ACTIVE';

  factory RoleDetail.fromJson(Map<String, dynamic> json) {
    return RoleDetail(
      roleId: json['roleId'] as int,
      roleName: json['roleName'] as String,
      activities: (json['activities'] as List<dynamic>).cast<String>(),
      status: json['status'] as String,
    );
  }
}
