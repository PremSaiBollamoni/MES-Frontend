/// One present-today operator with whatever allocation/tracking state they
/// currently have, for the Supervisor's daily allocation roster.
class RosterEntry {
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final int? allocationId;
  final int? stationId;
  final String? stationNumber;
  final String? operationName;
  final int? activeTrackingSessionId;

  const RosterEntry({
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    this.allocationId,
    this.stationId,
    this.stationNumber,
    this.operationName,
    this.activeTrackingSessionId,
  });

  bool get isAssigned => stationId != null;
  bool get isTracking => activeTrackingSessionId != null;

  factory RosterEntry.fromJson(Map<String, dynamic> json) {
    return RosterEntry(
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String,
      employeeCode: json['employeeCode'] as String?,
      allocationId: (json['allocationId'] as num?)?.toInt(),
      stationId: (json['stationId'] as num?)?.toInt(),
      stationNumber: json['stationNumber'] as String?,
      operationName: json['operationName'] as String?,
      activeTrackingSessionId: (json['activeTrackingSessionId'] as num?)?.toInt(),
    );
  }
}
