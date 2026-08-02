import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../utils/theme_tokens.dart';
import 'entry_pickers.dart';

/// Supervisor form for logging pieces produced on behalf of an operator -
/// operators never fill this in themselves (PALMS §5 constraint).
///
/// The form itself stays short: four compact fields and a button. Choosing a station or
/// an operator opens a dedicated full-screen page rather than a dropdown, because with
/// 39 stations and 100+ operators a dropdown means scanning a seven-row window while
/// standing at a machine.
class LogProductionEntryDialog extends StatefulWidget {
  final List<RosterEntry> operators;
  final List<Station> stations;
  final Future<void> Function(int employeeId, int stationId, int pieces, double minutes) onSubmit;

  const LogProductionEntryDialog({super.key, required this.operators, required this.stations, required this.onSubmit});

  @override
  State<LogProductionEntryDialog> createState() => _LogProductionEntryDialogState();
}

class _LogProductionEntryDialogState extends State<LogProductionEntryDialog> {
  Station? _station;
  RosterEntry? _operator;
  final _piecesController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _piecesController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = (isStart ? _startTime : _endTime) ?? TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _chooseStation() async {
    final chosen = await pickStation(context, widget.stations, _station?.id);
    if (chosen == null) return;
    setState(() {
      _station = chosen;
      // If exactly one person is allocated to this station, they are almost certainly
      // who this entry is for - preselect them so the common case is one tap shorter.
      // Anything ambiguous is left for the supervisor to choose explicitly.
      final allocated = widget.operators.where((e) => e.stationId == chosen.id).toList();
      if (_operator == null && allocated.length == 1) _operator = allocated.first;
    });
  }

  Future<void> _chooseOperator() async {
    final chosen = await pickOperator(context, widget.operators, _operator?.employeeId, _station?.id);
    if (chosen == null) return;
    setState(() => _operator = chosen);
  }

  Future<void> _submit() async {
    final pieces = int.tryParse(_piecesController.text.trim());
    if (_operator == null || _station == null || pieces == null || _startTime == null || _endTime == null) {
      setState(() => _error = L10n.of(context).fillInEveryFieldWith);
      return;
    }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    var endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    // Shifts crossing midnight (end clock-time earlier than start) add a full day
    // rather than yielding a negative duration.
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    final minutes = (endMinutes - startMinutes).toDouble();
    if (minutes <= 0) {
      setState(() => _error = L10n.of(context).endTimeMustBeAfter);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_operator!.employeeId, _station!.id, pieces, minutes);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = e.toString().replaceAll("Exception: ", "");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
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
                  Expanded(child: Text(t.logProduction, style: ThemeTokens.headingMedium.copyWith(fontSize: 18))),
                  InkWell(
                    onTap: _isSaving ? null : () => Navigator.of(context).pop(),
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
                subvalue: _station?.operationName,
                placeholder: t.select,
                onTap: _chooseStation,
              ),
              const SizedBox(height: 12.0),
              PickerField(
                label: t.operator.toUpperCase(),
                icon: Icons.person_rounded,
                value: _operator?.employeeName,
                subvalue: _operator?.employeeCode,
                placeholder: t.select,
                onTap: _chooseOperator,
              ),
              const SizedBox(height: 12.0),
              TextField(
                controller: _piecesController,
                keyboardType: TextInputType.number,
                style: ThemeTokens.headingMedium.copyWith(fontSize: 22),
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
              Row(
                children: [
                  Expanded(child: _TimeField(label: t.startTime, time: _startTime, onTap: () => _pickTime(true))),
                  const SizedBox(width: 12.0),
                  Expanded(child: _TimeField(label: t.endTime, time: _endTime, onTap: () => _pickTime(false))),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12.0),
                Text(_error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 22.0),
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

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  const _TimeField({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final chosen = time != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: chosen ? ThemeTokens.primary : ThemeTokens.hairline, width: chosen ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 9.5)),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: chosen ? ThemeTokens.primary : ThemeTokens.textLight),
                const SizedBox(width: 8.0),
                Text(
                  chosen ? time!.format(context) : L10n.of(context).select,
                  style: ThemeTokens.bodyLarge.copyWith(
                    fontSize: 14,
                    color: chosen ? ThemeTokens.textPrimary : ThemeTokens.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
