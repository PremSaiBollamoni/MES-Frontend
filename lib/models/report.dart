enum ReportType {
  production,
  stock,
  attendance,
  workerPerformance;

  String get apiValue {
    switch (this) {
      case ReportType.production:
        return 'PRODUCTION';
      case ReportType.stock:
        return 'STOCK';
      case ReportType.attendance:
        return 'ATTENDANCE';
      case ReportType.workerPerformance:
        return 'WORKER_PERFORMANCE';
    }
  }
}

class ReportSummary {
  final int id;
  final String reportDate;
  final String generatedAt;
  final String modelUsed;

  const ReportSummary({
    required this.id,
    required this.reportDate,
    required this.generatedAt,
    required this.modelUsed,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      id: json['id'] as int,
      reportDate: json['reportDate'] as String,
      generatedAt: json['generatedAt'] as String,
      modelUsed: json['modelUsed'] as String,
    );
  }
}
