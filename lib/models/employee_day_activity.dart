import 'production_entry.dart';
import 'tracking_session.dart';

/// One employee's full activity for a given shift date, unioned from two
/// independent sources: an active [TrackingSession] (team tracking, so one
/// session can cover several employees) and their [ProductionEntry] rows.
/// An employee can have more than one completed entry per day because
/// ProductionEntry is unique per employee+station+day, not per employee+day
/// (e.g. they worked Fusing in the morning and Stitching in the afternoon).
class EmployeeDayActivity {
  final int employeeId;
  final String employeeName;
  final TrackingSession? activeSession;
  final List<ProductionEntry> entries;

  const EmployeeDayActivity({
    required this.employeeId,
    required this.employeeName,
    required this.entries,
    this.activeSession,
  });

  bool get isInProgress => activeSession != null;

  double get averageEfficiency {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.efficiencyPct).reduce((a, b) => a + b) / entries.length;
  }

  String get summaryLine {
    if (isInProgress) {
      return "In Progress · ${activeSession!.stationNumber}";
    }
    if (entries.isEmpty) return "No completed entries";
    if (entries.length == 1) {
      final e = entries.first;
      return "${e.operationName} · ${e.efficiencyPct.toStringAsFixed(0)}%";
    }
    // Name every job, not just a count - a bare "N entries" reads as if earlier
    // jobs vanished when in fact all of them are still there (PALMS §10 - an
    // operator can log more than one station per day).
    final jobNames = entries.map((e) => e.operationName).join(" · ");
    return "$jobNames · avg ${averageEfficiency.toStringAsFixed(0)}%";
  }

  static Map<int, EmployeeDayActivity> groupByEmployee({
    required List<ProductionEntry> entries,
    required List<TrackingSession> activeSessions,
  }) {
    final Map<int, EmployeeDayActivity> byEmployee = {};

    for (final session in activeSessions) {
      for (final ref in session.employees) {
        final existing = byEmployee[ref.employeeId];
        byEmployee[ref.employeeId] = EmployeeDayActivity(
          employeeId: ref.employeeId,
          employeeName: ref.employeeName,
          activeSession: session,
          entries: existing?.entries ?? const [],
        );
      }
    }

    for (final entry in entries) {
      final existing = byEmployee[entry.employeeId];
      byEmployee[entry.employeeId] = EmployeeDayActivity(
        employeeId: entry.employeeId,
        employeeName: entry.employeeName,
        activeSession: existing?.activeSession,
        entries: [...(existing?.entries ?? const []), entry],
      );
    }

    return byEmployee;
  }

  static List<EmployeeDayActivity> sorted(Map<int, EmployeeDayActivity> byEmployee) {
    final list = byEmployee.values.toList();
    list.sort((a, b) {
      if (a.isInProgress != b.isInProgress) return a.isInProgress ? -1 : 1;
      return a.employeeName.compareTo(b.employeeName);
    });
    return list;
  }
}
