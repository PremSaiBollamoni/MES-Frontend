import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/station.dart';
import '../../utils/error_messages.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';
import 'entry_pickers.dart';
import 'shift_slots.dart';

/// Logs one stretch of work inside a single hourly slot.
///
/// The operator is already known (chosen on the previous screen) and the hour is fixed by
/// the slot, so this asks only for station, pieces, and optionally a narrower time range
/// within the hour. Adjusting the times matters when an operator split the hour across two
/// stations, since each entry then carries its real length instead of both claiming the
/// whole hour.
///
/// The times default to the first stretch still free in the hour, and anything overlapping
/// an existing entry is refused: one person cannot be at two stations at once, and an hour
/// that accumulated more than 60 minutes of work would understate every efficiency figure
/// computed from it.
class SlotEntryDialog extends StatefulWidget {
  final ShiftSlot slot;
  final String employeeName;
  final List<Station> stations;

  /// Stretches of this hour already claimed by existing entries.
  final List<TimeRange> taken;

  /// Times are sent as "HH:mm:ss" to match the backend's LocalTime format.
  final Future<void> Function(int stationId, int pieces, String startTime, String endTime, String? colour) onSubmit;

  const SlotEntryDialog({
    super.key,
    required this.slot,
    required this.employeeName,
    required this.stations,
    required this.onSubmit,
    this.taken = const [],
  });

  @override
  State<SlotEntryDialog> createState() => _SlotEntryDialogState();
}

class _SlotEntryDialogState extends State<SlotEntryDialog> {
  Station? _station;
  final _piecesController = TextEditingController();
  final _colourController = TextEditingController();
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Start where the hour is next free rather than at the top of the hour, so the common
    // case (log 09:00-09:20, then log the rest) needs no manual time fiddling at all.
    final freeStart = TimeRange.nextFreeStart(widget.slot, widget.taken) ?? widget.slot.startMinutes;
    _start = _timeOf(freeStart);
    _end = _timeOf(_freeEndAfter(freeStart));
  }

  static TimeOfDay _timeOf(int minutes) => TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  /// How far the free stretch beginning at [from] runs before it hits the next booking
  /// or the end of the slot.
  int _freeEndAfter(int from) {
    var limit = widget.slot.endMinutes;
    for (final range in widget.taken) {
      if (range.startMinutes >= from && range.startMinutes < limit) limit = range.startMinutes;
    }
    return limit;
  }

  @override
  void dispose() {
    _piecesController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  int _minutesOf(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Opens the clock, then refuses anything outside this slot rather than silently
  /// clamping it - a supervisor who picks 11:15 for the 10:00 hour has misread the
  /// screen, and quietly rewriting their input to 11:00 would hide that.
  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      helpText: widget.slot.label,
    );
    if (picked == null || !mounted) return;

    final minutes = _minutesOf(picked);
    if (minutes < widget.slot.startMinutes || minutes > widget.slot.endMinutes) {
      setState(() => _error = L10n.of(context).timeMustBeWithinSlot(widget.slot.label));
      return;
    }

    setState(() {
      _error = null;
      if (isStart) {
        _start = picked;
        if (_minutesOf(_end) <= minutes) _end = widget.slot.end;
      } else {
        _end = picked;
        if (minutes <= _minutesOf(_start)) _start = widget.slot.start;
      }
    });
  }

  /// The existing entry the chosen times run into, if any.
  TimeRange? _clashingRange() {
    final chosen = TimeRange(_minutesOf(_start), _minutesOf(_end));
    for (final range in widget.taken) {
      if (chosen.overlaps(range)) return range;
    }
    return null;
  }

  static String _rangeLabel(TimeRange r) =>
      '${_pad(r.startMinutes)} - ${_pad(r.endMinutes)}';

  static String _pad(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  String _clock(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _submit() async {
    final t = L10n.of(context);
    final pieces = int.tryParse(_piecesController.text.trim());
    if (_station == null || pieces == null) {
      setState(() => _error = t.fillInEveryFieldWith);
      return;
    }
    if (_minutesOf(_end) <= _minutesOf(_start)) {
      setState(() => _error = t.errEndBeforeStart);
      return;
    }
    final clash = _clashingRange();
    if (clash != null) {
      setState(() => _error = t.timeOverlapsAnotherEntry(_rangeLabel(clash)));
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final colour = _colourController.text.trim();
      await widget.onSubmit(_station!.id, pieces, _clock(_start), _clock(_end), colour.isEmpty ? null : colour);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _error = ErrorMessages.translate(context, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    final durationMinutes = _minutesOf(_end) - _minutesOf(_start);
    final freeMinutes = TimeRange.freeMinutes(widget.slot, widget.taken);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      backgroundColor: ThemeTokens.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.slot.label, style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
                        const SizedBox(height: 2.0),
                        Text(widget.employeeName, style: ThemeTokens.caption),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _isSaving ? null : () => Navigator.of(context).pop(false),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.close_rounded, color: ThemeTokens.textLight, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              PickerField(
                label: t.station.toUpperCase(),
                icon: Icons.factory_rounded,
                value: _station?.stationNumber,
                subvalue: _station == null ? null : OperationNames.display(context, _station!.operationName),
                placeholder: t.select,
                onTap: () async {
                  final chosen = await pickStation(context, widget.stations, _station?.id);
                  if (chosen != null) setState(() => _station = chosen);
                },
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: _piecesController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: ThemeTokens.headingMedium.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: t.piecesProduced.toUpperCase(),
                  labelStyle: ThemeTokens.labelSmall.copyWith(fontSize: 9.5),
                  hintText: "0",
                  filled: true,
                  fillColor: ThemeTokens.surfaceSolid,
                  border: _border(),
                  enabledBorder: _border(),
                  focusedBorder: _border(focused: true),
                ),
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: _colourController,
                textCapitalization: TextCapitalization.words,
                style: ThemeTokens.bodyLarge.copyWith(fontSize: 15),
                decoration: InputDecoration(
                  labelText: t.colour.toUpperCase(),
                  labelStyle: ThemeTokens.labelSmall.copyWith(fontSize: 9.5),
                  filled: true,
                  fillColor: ThemeTokens.surfaceSolid,
                  border: _border(),
                  enabledBorder: _border(),
                  focusedBorder: _border(focused: true),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(child: _TimeBox(label: t.startTime, time: _start, onTap: () => _pickTime(isStart: true))),
                  const SizedBox(width: 12.0),
                  Expanded(child: _TimeBox(label: t.endTime, time: _end, onTap: () => _pickTime(isStart: false))),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.taken.isEmpty
                    ? t.minutesCount(durationMinutes)
                    : '${t.minutesCount(durationMinutes)}   ·   ${t.minutesFree(freeMinutes)}',
                style: ThemeTokens.caption,
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12.0),
                Text(_error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeTokens.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t.logEntry, style: ThemeTokens.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border({bool focused = false}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        borderSide: BorderSide(
          color: focused ? ThemeTokens.primary : ThemeTokens.hairline,
          width: focused ? 1.5 : 1,
        ),
      );
}

class _TimeBox extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeBox({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 9.5)),
            const SizedBox(height: 4.0),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 16, color: ThemeTokens.primary),
                const SizedBox(width: 8.0),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: ThemeTokens.bodyLarge.copyWith(fontSize: 15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
