class Station {
  final int id;
  final String stationNumber;
  final String operationName;
  final String zone;
  final double sam;
  final int operatorCount;
  final int targetPiecesPerHour;
  final int targetPiecesPerDay;
  final double ratePerPiece;
  final bool active;
  final double targetWagePerDay;
  final double targetWagePerMonth;
  final int minStockThreshold;
  final int maxStockThreshold;

  const Station({
    required this.id,
    required this.stationNumber,
    required this.operationName,
    required this.zone,
    required this.sam,
    required this.operatorCount,
    required this.targetPiecesPerHour,
    required this.targetPiecesPerDay,
    required this.ratePerPiece,
    required this.active,
    required this.targetWagePerDay,
    required this.targetWagePerMonth,
    required this.minStockThreshold,
    required this.maxStockThreshold,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: (json['id'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      zone: json['zone'] as String,
      sam: (json['sam'] as num).toDouble(),
      operatorCount: (json['operatorCount'] as num).toInt(),
      targetPiecesPerHour: (json['targetPiecesPerHour'] as num).toInt(),
      targetPiecesPerDay: (json['targetPiecesPerDay'] as num).toInt(),
      ratePerPiece: (json['ratePerPiece'] as num).toDouble(),
      active: json['active'] as bool,
      targetWagePerDay: (json['targetWagePerDay'] as num).toDouble(),
      targetWagePerMonth: (json['targetWagePerMonth'] as num).toDouble(),
      minStockThreshold: (json['minStockThreshold'] as num?)?.toInt() ?? 0,
      maxStockThreshold: (json['maxStockThreshold'] as num?)?.toInt() ?? 0,
    );
  }
}

class StationRequest {
  final String? stationNumber;
  final String operationName;
  final String zone;
  final double sam;
  final int operatorCount;
  final int targetPiecesPerHour;
  final int targetPiecesPerDay;
  final double ratePerPiece;
  final bool? active;
  final int? minStockThreshold;
  final int? maxStockThreshold;

  const StationRequest({
    this.stationNumber,
    required this.operationName,
    required this.zone,
    required this.sam,
    required this.operatorCount,
    required this.targetPiecesPerHour,
    required this.targetPiecesPerDay,
    required this.ratePerPiece,
    this.active,
    this.minStockThreshold,
    this.maxStockThreshold,
  });

  Map<String, dynamic> toJson() => {
        if (stationNumber != null) 'stationNumber': stationNumber,
        'operationName': operationName,
        'zone': zone,
        'sam': sam,
        'operatorCount': operatorCount,
        'targetPiecesPerHour': targetPiecesPerHour,
        'targetPiecesPerDay': targetPiecesPerDay,
        'ratePerPiece': ratePerPiece,
        if (active != null) 'active': active,
        if (minStockThreshold != null) 'minStockThreshold': minStockThreshold,
        if (maxStockThreshold != null) 'maxStockThreshold': maxStockThreshold,
      };
}
