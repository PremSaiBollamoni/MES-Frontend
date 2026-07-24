import 'package:flutter/material.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../utils/theme_tokens.dart';

/// Supervisor form for logging pieces produced on behalf of an operator -
/// operators never fill this in themselves (PALMS §5 constraint). Only
/// operators present today (the same roster Allocation uses) are offered,
/// since production can't be logged for someone who didn't show up.
class LogProductionEntryDialog extends StatefulWidget {
  final List<RosterEntry> operators;
  final List<Station> stations;
  final Future<void> Function(int employeeId, int stationId, int pieces, double minutes) onSubmit;

  const LogProductionEntryDialog({super.key, required this.operators, required this.stations, required this.onSubmit});

  @override
  State<LogProductionEntryDialog> createState() => _LogProductionEntryDialogState();
}

class _LogProductionEntryDialogState extends State<LogProductionEntryDialog> {
  int? _employeeId;
  int? _stationId;
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

  Future<void> _submit() async {
    final pieces = int.tryParse(_piecesController.text.trim());
    if (_employeeId == null || _stationId == null || pieces == null || _startTime == null || _endTime == null) {
      setState(() => _error = "Fill in every field with valid values");
      return;
    }
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    var endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    // Shifts crossing midnight (end clock-time earlier than start) add a full day
    // rather than yielding a negative duration.
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    final minutes = (endMinutes - startMinutes).toDouble();
    if (minutes <= 0) {
      setState(() => _error = "End time must be after start time");
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_employeeId!, _stationId!, pieces, minutes);
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
    return AlertDialog(
      title: Text("Log Production", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _employeeId,
              isExpanded: true,
              hint: const Text("Operator"),
              items: widget.operators.map((e) => DropdownMenuItem(value: e.employeeId, child: Text(e.employeeName, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => setState(() => _employeeId = v),
            ),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<int>(
              initialValue: _stationId,
              isExpanded: true,
              hint: const Text("Station"),
              items: widget.stations
                  .map((s) => DropdownMenuItem(value: s.id, child: Text("${s.stationNumber} · ${s.operationName}", overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _stationId = v),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _piecesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Pieces Produced"),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(child: _TimeField(label: "Start Time", time: _startTime, onTap: () => _pickTime(true))),
                const SizedBox(width: 12.0),
                Expanded(child: _TimeField(label: "End Time", time: _endTime, onTap: () => _pickTime(false))),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10.0),
              Text(_error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Log Entry"),
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  const _TimeField({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time != null ? time!.format(context) : "Select"),
      ),
    );
  }
}
