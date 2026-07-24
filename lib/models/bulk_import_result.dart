class BulkImportFailure {
  final String hrmsEmployeeCode;
  final String name;
  final String reason;

  const BulkImportFailure({required this.hrmsEmployeeCode, required this.name, required this.reason});

  factory BulkImportFailure.fromJson(Map<String, dynamic> json) {
    return BulkImportFailure(
      hrmsEmployeeCode: json['hrmsEmployeeCode'] as String,
      name: json['name'] as String,
      reason: json['reason'] as String,
    );
  }
}

class BulkImportResult {
  final int importedCount;
  final List<BulkImportFailure> failed;

  const BulkImportResult({required this.importedCount, required this.failed});

  factory BulkImportResult.fromJson(Map<String, dynamic> json) {
    return BulkImportResult(
      importedCount: (json['imported'] as List<dynamic>).length,
      failed: (json['failed'] as List<dynamic>).map((e) => BulkImportFailure.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
