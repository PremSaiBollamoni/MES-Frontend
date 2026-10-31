class FactoryDetail {
  final int factoryId;
  final String factoryName;
  final String factoryCode;
  final String? location;
  final bool hrmsEnabled;
  final String? hrmsConfigJson;
  final bool active;

  const FactoryDetail({
    required this.factoryId,
    required this.factoryName,
    required this.factoryCode,
    this.location,
    required this.hrmsEnabled,
    this.hrmsConfigJson,
    required this.active,
  });

  factory FactoryDetail.fromJson(Map<String, dynamic> json) {
    return FactoryDetail(
      factoryId: json['factoryId'] as int,
      factoryName: json['factoryName'] as String,
      factoryCode: json['factoryCode'] as String,
      location: json['location'] as String?,
      hrmsEnabled: json['hrmsEnabled'] as bool? ?? true,
      hrmsConfigJson: json['hrmsConfigJson'] as String?,
      active: json['active'] as bool? ?? true,
    );
  }
}

class FactoryCreateRequest {
  final String factoryName;
  final String factoryCode;
  final String? location;

  const FactoryCreateRequest({required this.factoryName, required this.factoryCode, this.location});

  Map<String, dynamic> toJson() => {
        'factoryName': factoryName,
        'factoryCode': factoryCode,
        if (location != null) 'location': location,
      };
}

class FactoryUpdateRequest {
  final String? factoryName;
  final String? factoryCode;
  final String? location;
  final bool? hrmsEnabled;
  final bool? isActive;

  const FactoryUpdateRequest({this.factoryName, this.factoryCode, this.location, this.hrmsEnabled, this.isActive});

  Map<String, dynamic> toJson() => {
        if (factoryName != null) 'factoryName': factoryName,
        if (factoryCode != null) 'factoryCode': factoryCode,
        if (location != null) 'location': location,
        if (hrmsEnabled != null) 'hrmsEnabled': hrmsEnabled.toString(),
        if (isActive != null) 'isActive': isActive.toString(),
      };
}

/// The HRMS connection details for one factory - either its own external HRMS,
/// or the HRMS this app's operator provides to factories that don't have one.
class HrmsFactoryConfig {
  final String baseUrl;
  final String username;
  final String password;

  const HrmsFactoryConfig({required this.baseUrl, required this.username, required this.password});

  factory HrmsFactoryConfig.fromJson(Map<String, dynamic> json) {
    return HrmsFactoryConfig(
      baseUrl: json['baseUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'baseUrl': baseUrl, 'username': username, 'password': password};
}
