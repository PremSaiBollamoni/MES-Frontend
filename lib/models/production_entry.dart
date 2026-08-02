class ProductionEntry {
  final int id;
  final int employeeId;
  final String employeeName;
  final int stationId;
  final String stationNumber;
  final String operationName;
  final String shiftDate;

  /// Clock times as "HH:mm:ss", or null for entries logged before hourly slots
  /// existed. Those older entries are shown under the day rather than an hour.
  final String? startTime;
  final String? endTime;

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
    this.startTime,
    this.endTime,
  });

  /// Hour this entry belongs to (0-23), or null if it predates slot tracking.
  int? get startHour {
    final t = startTime;
    if (t == null || t.length < 2) return null;
    return int.tryParse(t.substring(0, 2));
  }

  /// "09:00" style label for display, or null when there is no recorded time.
  String? get startLabel => startTime?.substring(0, 5);
  String? get endLabel => endTime?.substring(0, 5);

  factory ProductionEntry.fromJson(Map<String, dynamic> json) {
    return ProductionEntry(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String,
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      shiftDate: json['shiftDate'] as String,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
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

  /// "HH:mm:ss" clock times. The backend derives the duration from these, so
  /// timeOnMachineMinutes is not sent by the hourly-slot flow.
  final String? startTime;
  final String? endTime;
  final double? timeOnMachineMinutes;

  const LogProductionEntryRequest({
    required this.employeeId,
    required this.stationId,
    required this.shiftDate,
    required this.piecesProduced,
    this.startTime,
    this.endTime,
    this.timeOnMachineMinutes,
  });

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'stationId': stationId,
        'shiftDate': shiftDate,
        'piecesProduced': piecesProduced,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (timeOnMachineMinutes != null) 'timeOnMachineMinutes': timeOnMachineMinutes,
      };
}
