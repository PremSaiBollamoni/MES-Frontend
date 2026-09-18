import 'package:flutter/material.dart';
import '../../components/custom_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production_entry.dart';
import '../../models/station.dart';
import '../../services/production_entry_api_service.dart';
import '../../services/station_api_service.dart';
import '../../utils/error_messages.dart';
import '../../utils/theme_tokens.dart';
import 'edit_production_entry_form.dart';
import 'entry_pickers.dart';

/// Corrects an already-logged entry: station, pieces, colour, and the time range when the entry
/// has one. Capped server-side at two corrections per entry - this dialog only ever shows for an
/// entry that still has at least one left (see production_entry_detail_dialog.dart).
Future<bool?> showEditProductionEntryDialog(BuildContext context, ProductionEntry entry) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _EditProductionEntryDialog(entry: entry),
  );
}

class _EditProductionEntryDialog extends StatefulWidget {
  final ProductionEntry entry;
  const _EditProductionEntryDialog({required this.entry});

  @override
  State<_EditProductionEntryDialog> createState() => _EditProductionEntryDialogState();
}

class _EditProductionEntryDialogState extends State<_EditProductionEntryDialog> {
  late final TextEditingController _piecesController;
  late final TextEditingController _colourController;
  late int _stationId;
  String? _stationNumber;
  String? _operationName;
  TimeOfDay? _start;
  TimeOfDay? _end;
  List<Station> _stations = [];
  bool _isLoadingStations = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _piecesController = TextEditingController(text: '${e.piecesProduced}');
    _colourController = TextEditingController(text: e.colour ?? '');
    _stationId = e.stationId;
    _stationNumber = e.stationNumber;
    _operationName = e.operationName;
    _start = _parseTime(e.startTime);
    _end = _parseTime(e.endTime);
    _loadStations();
  }

  TimeOfDay? _parseTime(String? clock) {
    if (clock == null || clock.length < 5) return null;
    final h = int.tryParse(clock.substring(0, 2));
    final m = int.tryParse(clock.substring(3, 5));
    return h == null || m == null ? null : TimeOfDay(hour: h, minute: m);
  }

  Future<void> _loadStations() async {
    try {
      final stations = await StationApiService().listStations();
      if (!mounted) return;
      setState(() {
        _stations = stations;
        _isLoadingStations = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingStations = false);
    }
  }

  @override
  void dispose() {
    _piecesController.dispose();
    _colourController.dispose();
    super.dispose();
  }

  Future<void> _pickStation() async {
    final chosen = await pickStation(context, _stations, _stationId);
    if (chosen == null) return;
    setState(() {
      _stationId = chosen.id;
      _stationNumber = chosen.stationNumber;
      _operationName = chosen.operationName;
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(context: context, initialTime: (isStart ? _start : _end) ?? TimeOfDay.now());
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  String _clock(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _submit() async {
    final t = L10n.of(context);
    final pieces = int.tryParse(_piecesController.text.trim());
    if (pieces == null || pieces < 0) {
      setState(() => _error = t.fillInEveryFieldWith);
      return;
    }

    final hadTimes = widget.entry.startTime != null;
    if (hadTimes && (_start == null || _end == null)) {
      setState(() => _error = t.errTimeRequired);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      final request = EditProductionEntryRequest(
        stationId: _stationId,
        piecesProduced: pieces,
        startTime: hadTimes ? _clock(_start!) : null,
        endTime: hadTimes ? _clock(_end!) : null,
        colour: _colourController.text.trim(),
      );
      await ProductionEntryApiService().edit(widget.entry.id, request);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      CustomToast.show(context, 'Entry updated');
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
    final hasTimes = widget.entry.startTime != null;

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
                    child: Text('Correct Entry', style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
                  ),
                  Text('${widget.entry.editsRemaining}', style: ThemeTokens.caption),
                ],
              ),
              const SizedBox(height: 12.0),
              EditProductionEntryForm(
                piecesController: _piecesController,
                colourController: _colourController,
                stationNumber: _stationNumber,
                operationName: _operationName,
                isLoadingStations: _isLoadingStations,
                onPickStation: _pickStation,
                hasTimes: hasTimes,
                start: _start,
                end: _end,
                onPickStart: () => _pickTime(isStart: true),
                onPickEnd: () => _pickTime(isStart: false),
                error: _error,
              ),
              const SizedBox(height: 18.0),
              EditProductionEntryForm.actions(
                context: context,
                isSaving: _isSaving,
                onCancel: () => Navigator.of(context).pop(false),
                onSave: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
