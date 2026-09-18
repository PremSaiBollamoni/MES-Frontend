import 'user_model.dart';

class AvailableRole {
  final int roleId;
  final String roleName;

  const AvailableRole({required this.roleId, required this.roleName});

  factory AvailableRole.fromJson(Map<String, dynamic> json) {
    return AvailableRole(
      roleId: json['roleId'] as int,
      roleName: json['roleName'] as String,
    );
  }
}

/// A pending login for an employee who holds more than one active role - they
/// must pick one (via ApiService.selectRole) before a real session exists.
class RoleSelectionRequired {
  final int id;
  final String name;
  final String username;
  final List<AvailableRole> roles;
  final String preAuthToken;

  const RoleSelectionRequired({
    required this.id,
    required this.name,
    required this.username,
    required this.roles,
    required this.preAuthToken,
  });

  factory RoleSelectionRequired.fromJson(Map<String, dynamic> json) {
    return RoleSelectionRequired(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => AvailableRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      preAuthToken: json['preAuthToken'] as String,
    );
  }
}

/// Either a completed login (one role, or a role already chosen) or a pending
/// role-selection step for an employee with multiple roles.
class LoginResult {
  final UserModel? user;
  final RoleSelectionRequired? roleSelection;

  const LoginResult.success(UserModel this.user) : roleSelection = null;
  const LoginResult.roleSelectionRequired(RoleSelectionRequired this.roleSelection) : user = null;

  bool get requiresRoleSelection => roleSelection != null;
}
