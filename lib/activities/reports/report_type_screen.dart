import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../components/custom_toast.dart';
import '../../models/report.dart';
import '../../services/report_api_service.dart';
import '../../utils/theme_tokens.dart';
import '../operations/operations_widgets.dart';
import 'report_generate_button.dart';
import 'report_list_item.dart';
import 'report_pdf_opener.dart';
import 'report_period_selector.dart';
import 'report_provider_prefs.dart';
import 'report_provider_selector.dart';

/// Generic single-report-type screen: date picker, Generate button, list of previously
/// generated reports for that type. Each concrete report (Production/Stock/Attendance/Worker
/// Performance/Earnings) is just this widget configured with a type, title, and copy.
class ReportTypeScreen extends StatefulWidget {
  final ReportType reportType;
  final String title;
  final String emptyTitle;
  final String emptyBody;
  final String filenamePrefix;
  final bool supportsMonthly;
  final bool alwaysMonthly;

  const ReportTypeScreen({
    super.key,
    required this.reportType,
    required this.title,
    required this.emptyTitle,
    required this.emptyBody,
    required this.filenamePrefix,
    this.supportsMonthly = false,
    this.alwaysMonthly = false,
  });

  @override
  State<ReportTypeScreen> createState() => _ReportTypeScreenState();
}

class _ReportTypeScreenState extends State<ReportTypeScreen> {
  final _service = ReportApiService();

  DateTime _date = DateTime.now();
  ReportPeriod _period = ReportPeriod.daily;
  ReportProvider _provider = ReportProvider.claude;
  final _modelController = TextEditingController();
  List<ReportSummary> _reports = [];
  bool _loading = true;
  bool _generating = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.alwaysMonthly) _period = ReportPeriod.monthly;
    _loadReports();
    _loadProviderPrefs();
  }

  Future<void> _loadProviderPrefs() async {
    final (provider, model) = await ReportProviderPrefs.load();
    if (!mounted) return;
    setState(() {
      _provider = provider;
      _modelController.text = model;
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  static const _months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  String get _monthLabel => "${_months[_date.month - 1]} ${_date.year}";

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
      final model = _modelController.text.trim();
      final report = await _service.generateReport(
        formatIsoDate(_date),
        widget.reportType,
        force: force,
        period: _period,
        provider: _provider,
        model: model,
      );
      unawaited(ReportProviderPrefs.save(_provider, model));
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
            const SizedBox(height: 10.0),
            ReportPeriodSelector(
              showToggle: widget.supportsMonthly,
              period: _period,
              onChanged: (p) => setState(() => _period = p),
              monthLabel: _monthLabel,
            ),
            const SizedBox(height: 14.0),
            ReportProviderSelector(
              provider: _provider,
              onProviderChanged: (p) => setState(() => _provider = p),
              modelController: _modelController,
            ),
            const SizedBox(height: 14.0),
            ReportGenerateButton(generating: _generating, onPressed: () => _generate()),
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
                    setState(() {
                      _date = DateTime.parse(r.reportDate);
                      _period = r.periodType;
                    });
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
