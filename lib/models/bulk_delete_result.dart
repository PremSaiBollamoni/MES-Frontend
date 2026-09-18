class BulkDeleteResult {
  final int deletedCount;
  final List<BulkDeleteFailure> failed;

  const BulkDeleteResult({required this.deletedCount, required this.failed});

  factory BulkDeleteResult.fromJson(Map<String, dynamic> json) {
    return BulkDeleteResult(
      deletedCount: (json['deletedCount'] as num).toInt(),
      failed: (json['failed'] as List<dynamic>)
          .map((e) => BulkDeleteFailure.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BulkDeleteFailure {
  final int id;
  final String reason;

  const BulkDeleteFailure({required this.id, required this.reason});

  factory BulkDeleteFailure.fromJson(Map<String, dynamic> json) {
    return BulkDeleteFailure(
      id: (json['id'] as num).toInt(),
      reason: json['reason'] as String? ?? "Unknown error",
    );
  }
}
