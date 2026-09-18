import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/production_entry.dart';
import '../services/production_entry_api_service.dart';
import '../utils/error_messages.dart';
import '../utils/theme_tokens.dart';
import 'operations/operations_widgets.dart';
import 'operations/production_entry_detail_dialog.dart';
import 'my_daily_production_row.dart';

/// An operator's own production, one date at a time - every entry logged that day, not a
/// summary. Complements the Dashboard's month-level totals: this is for "what exactly did I
/// do on the 14th", which a running total can't answer.
///
/// Reads the same self-scoped endpoint the dashboard uses
/// (GET /api/production-entries/me) - no new API, so nothing here requires a backend change.
/// The endpoint takes a rolling day-count rather than an explicit date, so a wide window is
/// fetched once and every date change just re-filters what is already in memory.
class MyDailyProductionScreen extends StatefulWidget {
  const MyDailyProductionScreen({super.key});

  @override
  State<MyDailyProductionScreen> createState() => _MyDailyProductionScreenState();
}

class _MyDailyProductionScreenState extends State<MyDailyProductionScreen> {
  final _apiService = ProductionEntryApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ProductionEntry> _allEntries = [];
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // A year back covers any date an operator would plausibly want to look up, fetched
      // once; picking a different date is then a local filter, not a new network call.
      final entries = await _apiService.myEntries(days: 365, forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _allEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ErrorMessages.translate(context, e);
        _isLoading = false;
      });
    }
  }

  String get _iso => '${_date.year.toString().padLeft(4, '0')}-'
      '${_date.month.toString().padLeft(2, '0')}-'
      '${_date.day.toString().padLeft(2, '0')}';

  List<ProductionEntry> get _dayEntries =>
      _allEntries.where((e) => e.shiftDate == _iso).toList();

  void _shiftDay(int delta) {
    final next = _date.add(Duration(days: delta));
    if (next.isAfter(DateTime.now())) return; // no looking up work not yet done
    setState(() => _date = next);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: Column(
        children: [
          DailyProductionDateBar(
            date: _date,
            onPrevious: () => _shiftDay(-1),
            onNext: _date.isBefore(DateTime.now()) ? () => _shiftDay(1) : null,
            onPickDate: _pickDate,
          ),
          Expanded(child: _body(t)),
        ],
      ),
    );
  }

  Widget _body(L10n t) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: t.noEntriesForThisDate,
        body: _errorMessage!,
      );
    }

    final entries = _dayEntries;
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(t.noEntriesForThisDate, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          DailyProductionTotals(entries: entries),
          const SizedBox(height: 16.0),
          ...entries.map((e) => DailyProductionRow(
                entry: e,
                onTap: () => showProductionEntryDetailDialog(context, e),
              )),
        ],
      ),
    );
  }
}
