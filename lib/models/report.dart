enum ReportType {
  production,
  stock,
  attendance,
  workerPerformance,
  earnings;

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
      case ReportType.earnings:
        return 'EARNINGS';
    }
  }
}

enum ReportPeriod {
  daily,
  monthly;

  String get apiValue => this == ReportPeriod.monthly ? 'MONTHLY' : 'DAILY';

  static ReportPeriod fromApiValue(String? value) => value == 'MONTHLY' ? ReportPeriod.monthly : ReportPeriod.daily;
}

enum ReportProvider {
  claude,
  openRouter;

  String get apiValue => this == ReportProvider.openRouter ? 'OPENROUTER' : 'CLAUDE';
}

class ReportSummary {
  final int id;
  final String reportDate;
  final ReportPeriod periodType;
  final String generatedAt;
  final String modelUsed;

  const ReportSummary({
    required this.id,
    required this.reportDate,
    required this.periodType,
    required this.generatedAt,
    required this.modelUsed,
  });

  bool get isMonthly => periodType == ReportPeriod.monthly;

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      id: json['id'] as int,
      reportDate: json['reportDate'] as String,
      // Absent on responses from before this feature shipped rather than genuinely daily -
      // still defaults correctly since every pre-existing report was in fact daily.
      periodType: ReportPeriod.fromApiValue(json['periodType'] as String?),
      generatedAt: json['generatedAt'] as String,
      modelUsed: json['modelUsed'] as String,
    );
  }
}
