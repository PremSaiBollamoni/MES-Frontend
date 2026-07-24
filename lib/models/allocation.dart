class Allocation {
  final int id;
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final int stationId;
  final String stationNumber;
  final String operationName;
  final String shiftDate;
  final String shift;

  const Allocation({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    required this.stationId,
    required this.stationNumber,
    required this.operationName,
    required this.shiftDate,
    required this.shift,
  });

  factory Allocation.fromJson(Map<String, dynamic> json) {
    return Allocation(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      employeeName: json['employeeName'] as String,
      employeeCode: json['employeeCode'] as String?,
      stationId: (json['stationId'] as num).toInt(),
      stationNumber: json['stationNumber'] as String,
      operationName: json['operationName'] as String,
      shiftDate: json['shiftDate'] as String,
      shift: json['shift'] as String,
    );
  }
}

class AssignAllocationRequest {
  final int employeeId;
  final int stationId;
  final String shiftDate;
  final String shift;

  const AssignAllocationRequest({
    required this.employeeId,
    required this.stationId,
    required this.shiftDate,
    required this.shift,
  });

  Map<String, dynamic> toJson() => {
        'employeeId': employeeId,
        'stationId': stationId,
        'shiftDate': shiftDate,
        'shift': shift,
      };
}
