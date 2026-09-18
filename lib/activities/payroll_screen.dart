import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../components/custom_toast.dart';
import '../models/payroll_preview.dart';
import '../services/payroll_api_service.dart';
import '../utils/error_messages.dart';
import '../utils/theme_tokens.dart';
import 'operations/operations_widgets.dart';
import 'payroll_preview_list.dart';

/// HR-facing salary payroll: pick a date range, review every operator's earnings breakdown
/// live in the app, then download the same data as a ready-to-use Excel workbook.
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final _service = PayrollApiService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();
  List<PayrollOperatorRow>? _preview;
  bool _loadingPreview = false;
  bool _downloading = false;

  void _onDateChanged(DateTime Function() pick) {
    setState(() {
      pick();
      _preview = null; // a changed range invalidates the last preview
    });
  }

  Future<void> _generatePreview() async {
    if (_endDate.isBefore(_startDate)) {
      CustomToast.show(context, L10n.of(context).payrollEndBeforeStart, isError: true);
      return;
    }
    setState(() => _loadingPreview = true);
    try {
      final rows = await _service.previewPayroll(formatIsoDate(_startDate), formatIsoDate(_endDate));
      if (!mounted) return;
      setState(() => _preview = rows);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _loadingPreview = false);
    }
  }

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      final startIso = formatIsoDate(_startDate);
      final endIso = formatIsoDate(_endDate);
      final response = await _service.downloadPayrollXlsx(startIso, endIso);
      final filename = 'payroll_${startIso}_to_$endIso.xlsx';

      // Windows' native share sheet can't list share targets for a plain local file from
      // an unpackaged app ("Try that again"), so save straight to Downloads there instead
      // of going through Share - mobile keeps the share sheet, which works fine.
      if (Platform.isWindows) {
        final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
        final file = File('${dir.path}\\$filename');
        await file.writeAsBytes(response.bodyBytes);
        if (!mounted) return;
        CustomToast.show(context, '${L10n.of(context).payrollSavedTo} ${file.path}');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);
        if (!mounted) return;
        await Share.shareXFiles([XFile(file.path)]);
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        title: Text(t.payrollTitle, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        iconTheme: const IconThemeData(color: ThemeTokens.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text(t.payrollSubtitle, style: ThemeTokens.bodyMedium),
            const SizedBox(height: 20.0),
            Text(t.payrollStartDate, style: ThemeTokens.labelSmall),
            const SizedBox(height: 8.0),
            OpsDatePickerBar(date: _startDate, onChanged: (d) => _onDateChanged(() => _startDate = d)),
            const SizedBox(height: 16.0),
            Text(t.payrollEndDate, style: ThemeTokens.labelSmall),
            const SizedBox(height: 8.0),
            OpsDatePickerBar(date: _endDate, onChanged: (d) => _onDateChanged(() => _endDate = d)),
            const SizedBox(height: 24.0),
            _PayrollActionButton(
              label: t.payrollGenerateButton,
              loadingLabel: t.payrollGenerating,
              loading: _loadingPreview,
              onPressed: _generatePreview,
            ),
            if (_preview != null) ...[
              const SizedBox(height: 24.0),
              if (_preview!.isEmpty)
                OpsStateMessage(icon: Icons.people_outline_rounded, title: t.payrollPreviewEmpty, body: ''),
              if (_preview!.isNotEmpty) ...[
                PayrollPreviewList(rows: _preview!),
                const SizedBox(height: 8.0),
                _PayrollActionButton(
                  label: t.payrollDownloadButton,
                  loadingLabel: t.payrollDownloading,
                  loading: _downloading,
                  onPressed: _download,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PayrollActionButton extends StatelessWidget {
  final String label;
  final String loadingLabel;
  final bool loading;
  final VoidCallback onPressed;

  const _PayrollActionButton({
    required this.label,
    required this.loadingLabel,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primary,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
        ),
        child: loading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12.0),
                  Text(loadingLabel, style: ThemeTokens.buttonText),
                ],
              )
            : Text(label, style: ThemeTokens.buttonText),
      ),
    );
  }
}
