import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/stock_position.dart';
import '../../utils/theme_tokens.dart';

/// Dialog body for logging a zone's additions/dispatched for the day. Opening
/// balance is never entered here - it auto-carries-forward from the previous
/// day's closing balance on the backend.
class UpdateStockPositionDialog extends StatefulWidget {
  final StockPosition position;
  final Future<void> Function(int additions, int dispatched) onSubmit;

  const UpdateStockPositionDialog({super.key, required this.position, required this.onSubmit});

  @override
  State<UpdateStockPositionDialog> createState() => _UpdateStockPositionDialogState();
}

class _UpdateStockPositionDialogState extends State<UpdateStockPositionDialog> {
  late final TextEditingController _additionsController;
  late final TextEditingController _dispatchedController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _additionsController = TextEditingController(text: "${widget.position.additions}");
    _dispatchedController = TextEditingController(text: "${widget.position.dispatched}");
  }

  @override
  void dispose() {
    _additionsController.dispose();
    _dispatchedController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final additions = int.tryParse(_additionsController.text.trim());
    final dispatched = int.tryParse(_dispatchedController.text.trim());
    if (additions == null || dispatched == null) {
      setState(() => _error = L10n.of(context).enterValidWholeNumbers);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(additions, dispatched);
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
      title: Text(widget.position.zoneName, style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Opening balance: ${widget.position.openingBalance}", style: ThemeTokens.bodyMedium),
          const SizedBox(height: 12.0),
          TextField(
            controller: _additionsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: L10n.of(context).additions),
          ),
          const SizedBox(height: 12.0),
          TextField(
            controller: _dispatchedController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: L10n.of(context).dispatched),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10.0),
            Text(_error!, style: ThemeTokens.caption.copyWith(color: ThemeTokens.error)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop(), child: Text(L10n.of(context).cancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: ThemeTokens.primary, foregroundColor: Colors.white),
          child: _isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(L10n.of(context).save),
        ),
      ],
    );
  }
}
