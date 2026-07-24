class StockPosition {
  final String zoneCode;
  final String zoneName;
  final String positionDate;
  final int openingBalance;
  final int additions;
  final int dispatched;
  final int closingBalance;
  final int? maxAlertPieces;
  final bool alertTriggered;

  const StockPosition({
    required this.zoneCode,
    required this.zoneName,
    required this.positionDate,
    required this.openingBalance,
    required this.additions,
    required this.dispatched,
    required this.closingBalance,
    this.maxAlertPieces,
    required this.alertTriggered,
  });

  factory StockPosition.fromJson(Map<String, dynamic> json) {
    return StockPosition(
      zoneCode: json['zoneCode'] as String,
      zoneName: json['zoneName'] as String,
      positionDate: json['positionDate'] as String,
      openingBalance: (json['openingBalance'] as num).toInt(),
      additions: (json['additions'] as num).toInt(),
      dispatched: (json['dispatched'] as num).toInt(),
      closingBalance: (json['closingBalance'] as num).toInt(),
      maxAlertPieces: (json['maxAlertPieces'] as num?)?.toInt(),
      alertTriggered: json['alertTriggered'] as bool,
    );
  }
}

/// openingBalance is intentionally nullable - omit it so the backend
/// auto-carries-forward the previous day's closing balance instead.
class UpdateStockPositionRequest {
  final String zoneCode;
  final String positionDate;
  final int? openingBalance;
  final int additions;
  final int dispatched;

  const UpdateStockPositionRequest({
    required this.zoneCode,
    required this.positionDate,
    this.openingBalance,
    required this.additions,
    required this.dispatched,
  });

  Map<String, dynamic> toJson() => {
        'zoneCode': zoneCode,
        'positionDate': positionDate,
        'openingBalance': openingBalance,
        'additions': additions,
        'dispatched': dispatched,
      };
}
