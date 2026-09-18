class Bundle {
  final int id;
  final String bundleRef;
  final int quantity;
  final int? currentStationId;
  final String? currentStationNumber;
  final String? currentOperationName;
  final String status;
  final String createdAt;

  const Bundle({
    required this.id,
    required this.bundleRef,
    required this.quantity,
    this.currentStationId,
    this.currentStationNumber,
    this.currentOperationName,
    required this.status,
    required this.createdAt,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: (json['id'] as num).toInt(),
      bundleRef: json['bundleRef'] as String,
      quantity: (json['quantity'] as num).toInt(),
      currentStationId: (json['currentStationId'] as num?)?.toInt(),
      currentStationNumber: json['currentStationNumber'] as String?,
      currentOperationName: json['currentOperationName'] as String?,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

class CreateBundleRequest {
  final String bundleRef;
  final int quantity;
  final int initialStationId;

  const CreateBundleRequest({required this.bundleRef, required this.quantity, required this.initialStationId});

  Map<String, dynamic> toJson() => {
        'bundleRef': bundleRef,
        'quantity': quantity,
        'initialStationId': initialStationId,
      };
}

class StationWipSummary {
  final int stationId;
  final String stationNumber;
  final String operationName;
  final int bundleCount;
  final bool alertTriggered;

  const StationWipSummary({
    required this.stationId,
    required this.stationNumber,
    required this.operationName,
    required this.bundleCount,
    required this.alertTriggered,
  });

  factory StationWipSummary.fromJson(Map<String, dynamic> json) {
    return StationWipSummary(
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      bundleCount: (json['bundleCount'] as num).toInt(),
      alertTriggered: json['alertTriggered'] as bool,
    );
  }
}
