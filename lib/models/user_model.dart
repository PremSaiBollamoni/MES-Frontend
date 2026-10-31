class UserModel {
  final int id;
  final String name;
  final String username;
  final String role;
  final List<String> activities;

  /// Every active role this employee holds (not just [role], the one this session
  /// is currently signed in as). Drives whether "Switch Role" shows in the drawer.
  final List<String> availableRoles;

  /// The factory this session is scoped to. Absent (null) only for legacy cached
  /// sessions saved before multi-factory support - treat null as factory 1.
  final int? factoryId;

  /// True only for the system-wide SUPER_ADMIN role, which is not tied to any
  /// single factory and can see/manage all of them.
  final bool isSuperAdmin;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.activities,
    this.availableRoles = const [],
    this.factoryId,
    this.isSuperAdmin = false,
  });

  bool get hasMultipleRoles => availableRoles.length > 1;

  bool canAccess(String activityCode) => activities.contains(activityCode);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      activities: (json['activities'] as List<dynamic>? ?? []).cast<String>(),
      availableRoles: (json['availableRoles'] as List<dynamic>? ?? []).cast<String>(),
      factoryId: json['factoryId'] as int?,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'role': role,
      'activities': activities,
      'availableRoles': availableRoles,
      'factoryId': factoryId,
      'isSuperAdmin': isSuperAdmin,
    };
  }
}
