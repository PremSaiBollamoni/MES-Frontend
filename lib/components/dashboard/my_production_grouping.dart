import '../../models/production_entry.dart';

/// One calendar day's worth of the operator's entries, with the totals that matter to them
/// bundled alongside so the dashboard never has to re-sum the list to answer "how did today go".
class DayGroup {
  final String date;
  final List<ProductionEntry> entries;

  DayGroup(this.date, this.entries);

  int get pieces => entries.fold(0, (sum, e) => sum + e.piecesProduced);
  double get wages => entries.fold(0.0, (sum, e) => sum + e.wagesEarned);
  double get avgEfficiency =>
      entries.isEmpty ? 0 : entries.fold(0.0, (sum, e) => sum + e.efficiencyPct) / entries.length;
}

/// Groups entries by shift date, most recent first. The list itself already comes back
/// newest-first from the API, so grouping preserves that order rather than re-sorting.
List<DayGroup> groupByDay(List<ProductionEntry> entries) {
  final groups = <String, List<ProductionEntry>>{};
  for (final entry in entries) {
    groups.putIfAbsent(entry.shiftDate, () => []).add(entry);
  }
  return groups.entries.map((e) => DayGroup(e.key, e.value)).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

/// Today's entries specifically, matched against the device's local date - what an operator
/// means by "today" is their own clock, not the server's.
List<ProductionEntry> todaysEntries(List<ProductionEntry> entries, DateTime today) {
  return entries.where((e) => e.shiftDate == _isoDate(today)).toList();
}

/// Entries within the current calendar month - what an operator's wages are actually paid
/// against, unlike a rolling 30-day window which drifts across month boundaries and never
/// lines up with a payslip.
List<ProductionEntry> thisMonthsEntries(List<ProductionEntry> entries, DateTime today) {
  final prefix = '${today.year.toString().padLeft(4, '0')}-'
      '${today.month.toString().padLeft(2, '0')}-';
  return entries.where((e) => e.shiftDate.startsWith(prefix)).toList();
}

String _isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
