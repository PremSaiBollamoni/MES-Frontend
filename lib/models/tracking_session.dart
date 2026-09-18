/// Live team tracking session (PALMS §10) - mirrors TrackingSessionResponse.
/// A multi-operator station (e.g. Fusing, 2 operators) shares ONE session
/// across the whole team, so [employees] can hold more than one operator.
class TrackingSessionEmployeeRef {
  final int employeeId;
  final String employeeName;

  const TrackingSessionEmployeeRef({required this.employeeId, required this.employeeName});

  factory TrackingSessionEmployeeRef.fromJson(Map<String, dynamic> json) {
    return TrackingSessionEmployeeRef(
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String,
    );
  }
}

class TrackingSession {
  final int id;
  final List<TrackingSessionEmployeeRef> employees;
  final int stationId;
  final String stationNumber;
  final String operationName;
  final int requiredOperatorCount;
  final double standardSam;
  final double ratePerPiece;
  final String shiftDate;
  final int piecesIssued;
  // TOTAL for the team - divide by requiredOperatorCount for per-operator pay.
  final double estimatedWages;
  final String status;
  final String startedAt;
  final String? stoppedAt;
  final int? piecesCompleted;

  const TrackingSession({
    required this.id,
    required this.employees,
    required this.stationId,
    required this.stationNumber,
    required this.operationName,
    required this.requiredOperatorCount,
    required this.standardSam,
    required this.ratePerPiece,
    required this.shiftDate,
    required this.piecesIssued,
    required this.estimatedWages,
    required this.status,
    required this.startedAt,
    this.stoppedAt,
    this.piecesCompleted,
  });

  String get employeeNames => employees.map((e) => e.employeeName).join(", ");

  double get estimatedWagesPerOperator =>
      requiredOperatorCount > 0 ? estimatedWages / requiredOperatorCount : estimatedWages;

  factory TrackingSession.fromJson(Map<String, dynamic> json) {
    return TrackingSession(
      id: (json['id'] as num).toInt(),
      employees: (json['employees'] as List<dynamic>)
          .map((e) => TrackingSessionEmployeeRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      requiredOperatorCount: (json['requiredOperatorCount'] as num).toInt(),
      standardSam: (json['standardSam'] as num).toDouble(),
      ratePerPiece: (json['ratePerPiece'] as num).toDouble(),
      shiftDate: json['shiftDate'] as String,
      piecesIssued: (json['piecesIssued'] as num).toInt(),
      estimatedWages: (json['estimatedWages'] as num).toDouble(),
      status: json['status'] as String,
      startedAt: json['startedAt'] as String,
      stoppedAt: json['stoppedAt'] as String?,
      piecesCompleted: (json['piecesCompleted'] as num?)?.toInt(),
    );
  }
}

class StartTrackingRequest {
  final List<int> employeeIds;
  final int stationId;
  final String shiftDate;
  final int piecesIssued;

  const StartTrackingRequest({
    required this.employeeIds,
    required this.stationId,
    required this.shiftDate,
    required this.piecesIssued,
  });

  Map<String, dynamic> toJson() => {
        'employeeIds': employeeIds,
        'stationId': stationId,
        'shiftDate': shiftDate,
        'piecesIssued': piecesIssued,
      };
}

class StopTrackingRequest {
  final int? piecesCompleted;

  const StopTrackingRequest({this.piecesCompleted});

  Map<String, dynamic> toJson() => {
        if (piecesCompleted != null) 'piecesCompleted': piecesCompleted,
      };
}
