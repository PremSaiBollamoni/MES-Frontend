class StockAvailability {
  final int stationId;
  final String stationNumber;
  final String operationName;
  final int minStockThreshold;
  final int maxStockThreshold;
  final int currentStockQty;
  final String status; // NO_STOCK, LOW_STOCK, AVAILABLE, HIGH_STOCK, NOT_CHECKED
  final String? reason;
  final String? loggedAt;

  const StockAvailability({
    required this.stationId,
    required this.stationNumber,
    required this.operationName,
    required this.minStockThreshold,
    required this.maxStockThreshold,
    required this.currentStockQty,
    required this.status,
    this.reason,
    this.loggedAt,
  });

  factory StockAvailability.fromJson(Map<String, dynamic> json) {
    return StockAvailability(
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      minStockThreshold: (json['minStockThreshold'] as num?)?.toInt() ?? 0,
      maxStockThreshold: (json['maxStockThreshold'] as num?)?.toInt() ?? 0,
      currentStockQty: (json['currentStockQty'] as num?)?.toInt() ?? 0,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      loggedAt: json['loggedAt'] as String?,
    );
  }
}

class LogStockAvailabilityRequest {
  final int stationId;
  final String shiftDate;
  final int currentStockQty;
  final String? reason;

  const LogStockAvailabilityRequest({
    required this.stationId,
    required this.shiftDate,
    required this.currentStockQty,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'stationId': stationId,
        'shiftDate': shiftDate,
        'currentStockQty': currentStockQty,
        'reason': reason,
      };
}
