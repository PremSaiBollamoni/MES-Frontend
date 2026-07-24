class StationStatus {
  final int stationId;
  final String stationNumber;
  final String operationName;
  final String zone;
  final double sam;
  final int? allocatedEmployeeId;
  final String? allocatedEmployeeName;
  final String status; // UNALLOCATED, MANNED, UNMANNED
  final bool critical;

  const StationStatus({
    required this.stationId,
    required this.stationNumber,
    required this.operationName,
    required this.zone,
    required this.sam,
    this.allocatedEmployeeId,
    this.allocatedEmployeeName,
    required this.status,
    required this.critical,
  });

  factory StationStatus.fromJson(Map<String, dynamic> json) {
    return StationStatus(
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      zone: json['zone'] as String,
      sam: (json['sam'] as num).toDouble(),
      allocatedEmployeeId: (json['allocatedEmployeeId'] as num?)?.toInt(),
      allocatedEmployeeName: json['allocatedEmployeeName'] as String?,
      status: json['status'] as String,
      critical: json['critical'] as bool,
    );
  }
}
