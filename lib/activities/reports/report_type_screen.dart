import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../components/custom_toast.dart';
import '../../models/report.dart';
import '../../services/report_api_service.dart';
import '../../utils/theme_tokens.dart';
import '../operations/operations_widgets.dart';
import 'report_list_item.dart';
import 'report_pdf_opener.dart';

/// Generic single-report-type screen: date picker, Generate button, list of previously
/// generated reports for that type. Each concrete report (Production/Stock/Attendance/Worker
/// Performance) is just this widget configured with a type, title, and copy.
class ReportTypeScreen extends StatefulWidget {
  final ReportType reportType;
  final String title;
  final String emptyTitle;
  final String emptyBody;
  final String filenamePrefix;

  const ReportTypeScreen({
    super.key,
    required this.reportType,
    required this.title,
    required this.emptyTitle,
    required this.emptyBody,
    required this.filenamePrefix,
  });

  @override
  State<ReportTypeScreen> createState() => _ReportTypeScreenState();
}

class _ReportTypeScreenState extends State<ReportTypeScreen> {
  final _service = ReportApiService();

  DateTime _date = DateTime.now();
  List<ReportSummary> _reports = [];
  bool _loading = true;
  bool _generating = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final reports = await _service.listReports(widget.reportType, forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _reports = reports;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceAll("Exception: ", "");
        _loading = false;
      });
    }
  }

  Future<void> _generate({bool force = false}) async {
    setState(() => _generating = true);
    try {
      final report = await _service.generateReport(formatIsoDate(_date), widget.reportType, force: force);
      if (!mounted) return;
      CustomToast.show(context, force ? L10n.of(context).reportRegenerated : L10n.of(context).reportReady);
      await _loadReports();
      await _openReport(report);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _openReport(ReportSummary report) async {
    try {
      final response = await _service.downloadReportPdf(report.id);
      if (!mounted) return;
      await openReportResponse(context, response, "${widget.filenamePrefix}_${report.reportDate}.pdf");
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        backgroundColor: ThemeTokens.background,
        elevation: 0,
        title: Text(widget.title, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        iconTheme: const IconThemeData(color: ThemeTokens.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadReports(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            OpsDatePickerBar(date: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 14.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generating ? null : () => _generate(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeTokens.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
                ),
                child: _generating
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                          const SizedBox(width: 12.0),
                          Text(L10n.of(context).generatingAiReportThisCan, style: ThemeTokens.buttonText),
                        ],
                      )
                    : Text(L10n.of(context).generateReport, style: ThemeTokens.buttonText),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(L10n.of(context).previousReports, style: ThemeTokens.labelSmall),
            const SizedBox(height: 12.0),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Center(child: CircularProgressIndicator(color: ThemeTokens.primary)),
              )
            else if (_loadError != null)
              OpsStateMessage(icon: Icons.error_outline_rounded, title: L10n.of(context).couldnTLoadReports, body: _loadError!)
            else if (_reports.isEmpty)
              OpsStateMessage(icon: Icons.summarize_rounded, title: widget.emptyTitle, body: widget.emptyBody)
            else
              ..._reports.map(
                (r) => ReportListItem(
                  report: r,
                  onOpen: () => _openReport(r),
                  onRegenerate: () {
                    setState(() => _date = DateTime.parse(r.reportDate));
                    _generate(force: true);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
