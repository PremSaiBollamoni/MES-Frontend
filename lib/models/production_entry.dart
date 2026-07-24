class ProductionEntry {
  final int id;
  final int employeeId;
  final String employeeName;
  final int stationId;
  final String stationNumber;
  final String operationName;
  final String shiftDate;
  final int piecesProduced;
  final double timeOnMachineMinutes;
  final double samEarned;
  final double wagesEarned;
  final double efficiencyPct;
  final String classification; // CRITICAL, LOW, MARGINAL, GOOD, EXCELLENT

  const ProductionEntry({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.stationId,
    required this.stationNumber,
    required this.operationName,
    required this.shiftDate,
    required this.piecesProduced,
    required this.timeOnMachineMinutes,
    required this.samEarned,
    required this.wagesEarned,
    required this.efficiencyPct,
    required this.classification,
  });

  factory ProductionEntry.fromJson(Map<String, dynamic> json) {
    return ProductionEntry(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String,
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      shiftDate: json['shiftDate'] as String,
      piecesProduced: (json['piecesProduced'] as num).toInt(),
      timeOnMachineMinutes: (json['timeOnMachineMinutes'] as num).toDouble(),
      samEarned: (json['samEarned'] as num).toDouble(),
      wagesEarned: (json['wagesEarned'] as num).toDouble(),
      efficiencyPct: (json['efficiencyPct'] as num).toDouble(),
      classification: json['classification'] as String,
    );
  }
}

class LogProductionEntryRequest {
  final int employeeId;
  final int stationId;
  final String shiftDate;
  final int piecesProduced;
  final double timeOnMachineMinutes;

  const LogProductionEntryRequest({
    required this.employeeId,
    required this.stationId,
    required this.shiftDate,
    required this.piecesProduced,
    required this.timeOnMachineMinutes,
  });

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'stationId': stationId,
        'shiftDate': shiftDate,
        'piecesProduced': piecesProduced,
        'timeOnMachineMinutes': timeOnMachineMinutes,
      };
}
