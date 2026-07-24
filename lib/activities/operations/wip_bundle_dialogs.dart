import 'package:flutter/material.dart';
import '../../models/station.dart';
import '../../utils/theme_tokens.dart';

class CreateBundleDialog extends StatefulWidget {
  final List<Station> stations;
  final Future<void> Function(String bundleRef, int quantity, int initialStationId) onSubmit;

  const CreateBundleDialog({super.key, required this.stations, required this.onSubmit});

  @override
  State<CreateBundleDialog> createState() => _CreateBundleDialogState();
}

class _CreateBundleDialogState extends State<CreateBundleDialog> {
  final _refController = TextEditingController();
  final _qtyController = TextEditingController();
  int? _stationId;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _refController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ref = _refController.text.trim();
    final qty = int.tryParse(_qtyController.text.trim());
    if (ref.isEmpty || qty == null || _stationId == null) {
      setState(() => _error = "Fill in every field with valid values");
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(ref, qty, _stationId!);
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
      title: Text("Create Bundle", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _refController, decoration: const InputDecoration(labelText: "Bundle Reference")),
            const SizedBox(height: 12.0),
            TextField(controller: _qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity")),
            const SizedBox(height: 12.0),
            DropdownButtonFormField<int>(
              initialValue: _stationId,
              isExpanded: true,
              hint: const Text("Initial Station"),
              items: widget.stations
                  .map((s) => DropdownMenuItem(value: s.id, child: Text("${s.stationNumber} · ${s.operationName}", overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _stationId = v),
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
              : const Text("Create"),
        ),
      ],
    );
  }
}

class MoveBundleDialog extends StatefulWidget {
  final List<Station> stations;
  final Future<void> Function(int toStationId) onSubmit;

  const MoveBundleDialog({super.key, required this.stations, required this.onSubmit});

  @override
  State<MoveBundleDialog> createState() => _MoveBundleDialogState();
}

class _MoveBundleDialogState extends State<MoveBundleDialog> {
  int? _stationId;
  bool _isSaving = false;
  String? _error;

  Future<void> _submit() async {
    if (_stationId == null) {
      setState(() => _error = "Select a station");
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_stationId!);
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
      title: Text("Move Bundle", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
      content: DropdownButtonFormField<int>(
        initialValue: _stationId,
        isExpanded: true,
        hint: const Text("Move to Station"),
        items: widget.stations
            .map((s) => DropdownMenuItem(value: s.id, child: Text("${s.stationNumber} · ${s.operationName}", overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (v) => setState(() => _stationId = v),
      ),
      actions: [
        if (_error != null) Padding(padding: const EdgeInsets.only(right: 8.0), child: Text(_error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error))),
        TextButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Move"),
        ),
      ],
    );
  }
}
