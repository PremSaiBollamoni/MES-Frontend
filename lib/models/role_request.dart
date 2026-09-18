class RoleCreateRequest {
  final String roleName;
  final List<String> activities;

  const RoleCreateRequest({required this.roleName, required this.activities});

  Map<String, dynamic> toJson() => {'roleName': roleName, 'activities': activities};
}

class RoleUpdateRequest {
  final String? roleName;
  final List<String>? activities;
  final String? status;

  const RoleUpdateRequest({this.roleName, this.activities, this.status});

  Map<String, dynamic> toJson() => {
        if (roleName != null) 'roleName': roleName,
        if (activities != null) 'activities': activities,
        if (status != null) 'status': status,
      };
}
