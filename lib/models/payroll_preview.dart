/// One operation's contribution to an operator's payroll. Rate is always the station's real,
/// currently-configured rate - never derived from earnings/pieces - so pieces x rate only
/// equals earnings when operatorCount is 1; for a shared station, earnings is this operator's
/// split of the team's total.
class PayrollOperationLine {
  final String operationName;
  final int pieces;
  final double rate;
  final double earnings;
  final int operatorCount;

  const PayrollOperationLine({
    required this.operationName,
    required this.pieces,
    required this.rate,
    required this.earnings,
    required this.operatorCount,
  });

  bool get isShared => operatorCount > 1;

  factory PayrollOperationLine.fromJson(Map<String, dynamic> json) => PayrollOperationLine(
        operationName: json['operationName'] as String,
        pieces: (json['pieces'] as num).toInt(),
        rate: (json['rate'] as num).toDouble(),
        earnings: (json['earnings'] as num).toDouble(),
        operatorCount: (json['operatorCount'] as num?)?.toInt() ?? 1,
      );
}

/// One operator's payroll row - the same data the Payroll Excel sheet is built from.
class PayrollOperatorRow {
  final String operatorName;
  final List<PayrollOperationLine> operations;
  final double totalEarnings;
  final String? bankName;
  final String? bankAccountNumber;
  final String? ifscCode;

  const PayrollOperatorRow({
    required this.operatorName,
    required this.operations,
    required this.totalEarnings,
    this.bankName,
    this.bankAccountNumber,
    this.ifscCode,
  });

  bool get hasBankDetails => bankName != null || bankAccountNumber != null || ifscCode != null;

  factory PayrollOperatorRow.fromJson(Map<String, dynamic> json) => PayrollOperatorRow(
        operatorName: json['operatorName'] as String,
        operations: (json['operations'] as List)
            .map((e) => PayrollOperationLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalEarnings: (json['totalEarnings'] as num).toDouble(),
        bankName: json['bankName'] as String?,
        bankAccountNumber: json['bankAccountNumber'] as String?,
        ifscCode: json['ifscCode'] as String?,
      );
}
