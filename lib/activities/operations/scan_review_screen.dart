import 'package:flutter/material.dart';
import '../../components/custom_toast.dart';
import '../../models/scanned_page.dart';
import '../../models/station.dart';
import '../../services/scan_api_service.dart';
import '../../utils/employee_names.dart';
import '../../utils/error_messages.dart';
import '../../utils/theme_tokens.dart';
import 'scan_row_card.dart';
import 'scan_review_widgets.dart';
import 'scan_widgets.dart';

/// Review and correct a scanned page, then commit it to the production log.
///
/// The supervisor is the checkpoint here: the reading is a draft until they press save, and
/// every row they must resolve is surfaced at the top rather than left to be discovered.
class ScanReviewScreen extends StatefulWidget {
  final ScannedPage page;
  final List<Station> stations;

  const ScanReviewScreen({super.key, required this.page, required this.stations});

  @override
  State<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  final _apiService = ScanApiService();
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(widget.page.shiftDate ?? '') ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      widget.page.shiftDate = picked.toIso8601String().split('T').first;
    });
  }

  /// Adds an hour the reading missed. Only hours not already present are offered, so the page
  /// can never end up with two rows claiming the same hour.
  Future<void> _addRow() async {
    final used = widget.page.rows.map((r) => r.hour).toSet();
    final free = [for (var h = 1; h <= kShiftHourLabels.length; h++) if (!used.contains(h)) h];
    if (free.isEmpty) {
      CustomToast.show(context, 'All eight hours are already on this page', isError: true);
      return;
    }

    final chosen = await showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Add an hour'),
        children: free
            .map((h) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, h),
                  child: Text('$h   ·   ${kShiftHourLabels[h - 1]}'),
                ))
            .toList(),
      ),
    );
    if (chosen == null) return;
    setState(() {
      widget.page.rows
        ..add(ScannedRow(hour: chosen))
        ..sort((a, b) => a.hour - b.hour);
    });
  }

  Future<void> _save() async {
    final page = widget.page;
    if (page.shiftDate == null) {
      CustomToast.show(context, 'Set the date for this page first', isError: true);
      return;
    }
    if (page.saveableCount == 0) {
      CustomToast.show(context, 'Nothing to save on this page', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final created = await _apiService.confirm(page);
      if (!mounted) return;
      CustomToast.show(context, '$created entries saved');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final wide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(EmployeeNames.display(context, page.employeeName),
                style: ThemeTokens.headingMedium.copyWith(fontSize: 16),
                overflow: TextOverflow.ellipsis),
            Text('Review scanned page', style: ThemeTokens.caption),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 720 : double.infinity),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              ScanPageSummary(page: page, onPickDate: _pickDate),
              if (page.dateWarning != null) ScanWarningBanner(message: page.dateWarning!),
              if (page.attentionCount > 0)
                ScanWarningBanner(
                    message: '${page.attentionCount} row(s) need your attention before saving.'),
              const SizedBox(height: 16.0),
              Text('HOURS', style: ThemeTokens.labelSmall.copyWith(fontSize: 9.5)),
              const SizedBox(height: 8.0),
              if (page.rows.isEmpty)
                Text('No rows were read from this page.', style: ThemeTokens.bodyMedium)
              else
                ...page.rows.map((row) => ScanRowCard(
                      row: row,
                      stations: widget.stations,
                      onChanged: () => setState(() {}),
                      onRemove: () => setState(() => page.rows.remove(row)),
                    )),
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add an hour the scan missed'),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Each count becomes one entry, timed inside its hour.',
                style: ThemeTokens.caption.copyWith(fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ScanSaveBar(
          entryCount: page.entryCount, isSaving: _isSaving, onSave: _save),
    );
  }



}
