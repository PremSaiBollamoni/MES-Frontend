import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production_entry.dart';
import '../../models/station.dart';
import '../../services/production_entry_api_service.dart';
import '../../utils/employee_names.dart';
import '../../utils/error_messages.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'production_entry_detail_dialog.dart';
import 'shift_slots.dart';
import 'slot_entry_dialog.dart';

/// One operator's day, broken into hourly slots.
///
/// Each slot shows what has already been logged in that hour and offers a + to add more,
/// since an operator can move between stations within a single hour. Entries logged
/// before hourly slots existed have no recorded time, so they are collected in a separate
/// section at the bottom rather than being hidden or misfiled into an arbitrary hour.
class EmployeeSlotsScreen extends StatefulWidget {
  final int employeeId;
  final String employeeName;
  final DateTime date;
  final List<Station> stations;

  const EmployeeSlotsScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.stations,
  });

  @override
  State<EmployeeSlotsScreen> createState() => _EmployeeSlotsScreenState();
}

class _EmployeeSlotsScreenState extends State<EmployeeSlotsScreen> {
  final _apiService = ProductionEntryApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ProductionEntry> _entries = [];
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = true}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final all = await _apiService.listForDate(formatIsoDate(widget.date), forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _entries = all.where((e) => e.employeeId == widget.employeeId).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ErrorMessages.translate(context, e);
        _isLoading = false;
      });
    }
  }

  List<ProductionEntry> _entriesIn(ShiftSlot slot) =>
      _entries.where((e) => slot.contains(e.startTime)).toList();

  List<ProductionEntry> get _untimed => _entries.where((e) => e.startTime == null).toList();

  /// The stretches of [slot] already claimed, so a new entry cannot double-book them.
  /// An entry running past the slot end is clipped to it rather than dropped, so the
  /// minutes it really occupies inside this hour still count as taken.
  List<TimeRange> _takenIn(ShiftSlot slot) {
    final ranges = <TimeRange>[];
    for (final entry in _entriesIn(slot)) {
      final start = ShiftSlot.minutesOf(entry.startTime);
      if (start == null) continue;
      final end = ShiftSlot.minutesOf(entry.endTime) ?? slot.endMinutes;
      ranges.add(TimeRange(start, end > slot.endMinutes ? slot.endMinutes : end));
    }
    return ranges;
  }

  Future<void> _addEntry(ShiftSlot slot) async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => SlotEntryDialog(
        slot: slot,
        employeeName: EmployeeNames.display(context, widget.employeeName),
        stations: widget.stations,
        taken: _takenIn(slot),
        onSubmit: (stationId, pieces, startTime, endTime, colour) async {
          await _apiService.log(LogProductionEntryRequest(
            employeeId: widget.employeeId,
            stationId: stationId,
            shiftDate: formatIsoDate(widget.date),
            piecesProduced: pieces,
            startTime: startTime,
            endTime: endTime,
            colour: colour,
          ));
        },
      ),
    );
    if (added == true) {
      _changed = true;
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        backgroundColor: ThemeTokens.background,
        appBar: AppBar(
          backgroundColor: ThemeTokens.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: ThemeTokens.textPrimary),
            onPressed: () => Navigator.of(context).pop(_changed),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EmployeeNames.display(context, widget.employeeName),
                style: ThemeTokens.headingMedium.copyWith(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              Text(formatLongDate(widget.date), style: ThemeTokens.caption),
            ],
          ),
        ),
        body: _buildBody(t),
      ),
    );
  }

  Widget _buildBody(L10n t) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: t.couldnTLoadProductionEntries,
        body: _errorMessage!,
      );
    }

    final untimed = _untimed;

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _DayTotal(entries: _entries),
          const SizedBox(height: 12.0),
          ...ShiftSlot.all.map((slot) => _SlotCard(
                slot: slot,
                entries: _entriesIn(slot),
                freeMinutes: TimeRange.freeMinutes(slot, _takenIn(slot)),
                onAdd: () => _addEntry(slot),
                onDeleted: () => _load(forceRefresh: true),
              )),
          if (untimed.isNotEmpty) ...[
            const SizedBox(height: 18.0),
            Text(t.entriesWithoutATime.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 9.5)),
            const SizedBox(height: 8.0),
            ...untimed.map((e) => _EntryRow(entry: e, onDeleted: () => _load(forceRefresh: true))),
          ],
        ],
      ),
    );
  }
}

/// The operator's running day totals, recomputed from the entry list on every rebuild so
/// logging an entry updates them immediately without a separate refresh.
class _DayTotal extends StatelessWidget {
  final List<ProductionEntry> entries;
  const _DayTotal({required this.entries});

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final pieces = entries.fold<int>(0, (sum, e) => sum + e.piecesProduced);
    final minutes = entries.fold<double>(0, (sum, e) => sum + e.timeOnMachineMinutes);
    final wages = entries.fold<double>(0, (sum, e) => sum + e.wagesEarned);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: ThemeTokens.ink,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _Stat(label: t.piecesProduced, value: '$pieces', emphasis: true)),
              Expanded(child: _Stat(label: t.entries, value: '${entries.length}')),
            ],
          ),
          const SizedBox(height: 16.0),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(child: _Stat(label: t.timeOnMachine, value: _duration(minutes))),
              Expanded(
                child: _Stat(
                  label: t.wagesEarned,
                  value: '₹${wages.toStringAsFixed(2)}',
                  color: ThemeTokens.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Machine time reads as "3h 20m" past an hour: a day's worth in raw minutes is a
  /// number supervisors have to convert in their head before it means anything.
  static String _duration(double minutes) {
    final total = minutes.round();
    if (total < 60) return '${total}m';
    return '${total ~/ 60}h ${total % 60}m';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool emphasis;

  const _Stat({required this.label, required this.value, this.color, this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: ThemeTokens.labelSmall.copyWith(fontSize: 9, color: ThemeTokens.textLight),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: ThemeTokens.headingLarge.copyWith(
            color: color ?? Colors.white,
            fontSize: emphasis ? 26 : 20,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// One hour of the shift. The + is withdrawn once the hour has no minutes left, since an
/// hour cannot hold more than 60 minutes of work and letting it would corrupt every
/// efficiency figure derived from the day.
class _SlotCard extends StatelessWidget {
  final ShiftSlot slot;
  final List<ProductionEntry> entries;
  final int freeMinutes;
  final VoidCallback onAdd;
  final VoidCallback onDeleted;

  const _SlotCard({
    required this.slot,
    required this.entries,
    required this.freeMinutes,
    required this.onAdd,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final hasEntries = entries.isNotEmpty;
    final isFull = freeMinutes <= 0;
    final pieces = entries.fold<int>(0, (sum, e) => sum + e.piecesProduced);

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: hasEntries ? ThemeTokens.primary.withValues(alpha: 0.35) : ThemeTokens.hairline),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isFull ? null : onAdd,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 18, color: hasEntries ? ThemeTokens.primary : ThemeTokens.textLight),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(slot.label, style: ThemeTokens.bodyLarge.copyWith(fontSize: 15)),
                        // Only worth saying once part of the hour is spoken for.
                        if (hasEntries) ...[
                          const SizedBox(height: 2.0),
                          Text(
                            isFull ? t.hourIsFull : t.minutesFree(freeMinutes),
                            style: ThemeTokens.caption.copyWith(
                              fontSize: 10.5,
                              color: isFull ? ThemeTokens.textLight : ThemeTokens.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasEntries) ...[
                    Text('$pieces', style: ThemeTokens.headingMedium.copyWith(fontSize: 15, color: ThemeTokens.primary)),
                    const SizedBox(width: 10.0),
                  ],
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isFull ? ThemeTokens.surfaceSunken : ThemeTokens.primary,
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                    ),
                    child: Icon(
                      isFull ? Icons.check_rounded : Icons.add_rounded,
                      color: isFull ? ThemeTokens.textLight : Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasEntries)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                  children: entries
                      .map((e) => _EntryRow(entry: e, compact: true, onDeleted: onDeleted))
                      .toList()),
            ),
        ],
      ),
    );
  }
}

/// A single logged entry. Tapping opens the full detail - efficiency, wages, SAM earned
/// and time on machine - since the row itself only has room for a truncated subset.
class _EntryRow extends StatelessWidget {
  final ProductionEntry entry;
  final bool compact;
  final VoidCallback onDeleted;
  const _EntryRow({required this.entry, required this.onDeleted, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final times = entry.startLabel == null ? null : '${entry.startLabel} - ${entry.endLabel}';
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 6.0 : 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
        onTap: () async {
          // Reload when the entry was deleted from the detail view, so the day totals follow.
          final deleted = await showProductionEntryDetailDialog(context, entry);
          if (deleted == true) onDeleted();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSunken,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.stationNumber} · ${OperationNames.display(context, entry.operationName)}',
                      style: ThemeTokens.bodyMedium.copyWith(color: ThemeTokens.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (times != null) ...[
                      const SizedBox(height: 2.0),
                      Text('$times  ·  ${entry.timeOnMachineMinutes.round()} min',
                          style: ThemeTokens.caption.copyWith(fontSize: 10.5)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              Text('${entry.piecesProduced}', style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
              const SizedBox(width: 10.0),
              Text('${entry.efficiencyPct.round()}%',
                  style: ThemeTokens.caption.copyWith(
                      color: classificationColor(entry.classification), fontWeight: FontWeight.w700)),
              const SizedBox(width: 4.0),
              const Icon(Icons.chevron_right_rounded, size: 16, color: ThemeTokens.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
