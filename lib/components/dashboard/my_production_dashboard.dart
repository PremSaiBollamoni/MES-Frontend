import 'package:flutter/material.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../activities/operations/operations_widgets.dart';
import '../../models/production_entry.dart';
import '../../services/production_entry_api_service.dart';
import '../../utils/theme_tokens.dart';
import '../app_button.dart';
import 'ledger_hero.dart';

/// Operator's own read-only view of their production - backed by
/// GET /api/production-entries/me. Read-only: operators never enter their
/// own pieces/time, the Production Supervisor does that on their behalf.
class MyProductionDashboard extends StatefulWidget {
  const MyProductionDashboard({super.key});

  @override
  State<MyProductionDashboard> createState() => _MyProductionDashboardState();
}

class _MyProductionDashboardState extends State<MyProductionDashboard> {
  final ProductionEntryApiService _apiService = ProductionEntryApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ProductionEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final entries = await _apiService.myEntries(days: 30);
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
            ],
          ),
        ),
      );
    }
    if (_entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(L10n.of(context).noProductionEntriesLoggedFor, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }

    final totalPieces = _entries.fold<int>(0, (sum, e) => sum + e.piecesProduced);
    final avgEfficiency = _entries.fold<double>(0, (sum, e) => sum + e.efficiencyPct) / _entries.length;
    final best = _entries.reduce((a, b) => b.efficiencyPct > a.efficiencyPct ? b : a);

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          LedgerHero(
            eyebrow: L10n.of(context).piecesLast30Days,
            value: "$totalPieces",
            stats: [
              (value: "${avgEfficiency.toStringAsFixed(0)}%", label: L10n.of(context).avgEfficiency),
              (value: "${best.efficiencyPct.toStringAsFixed(0)}%", label: L10n.of(context).bestDay),
              (value: "${_entries.length}", label: L10n.of(context).shiftsLogged),
            ],
          ),
          const SizedBox(height: 28.0),
          Row(
            children: [
              Container(width: 18, height: 2, color: ThemeTokens.primary),
              const SizedBox(width: 10.0),
              Text(L10n.of(context).recentEntries, style: ThemeTokens.labelSmall),
            ],
          ),
          const SizedBox(height: 8.0),
          ..._entries.map((e) => _EntryRow(entry: e)),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final ProductionEntry entry;
  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = classificationColor(entry.classification);
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.shiftDate, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14)),
                const SizedBox(height: 2.0),
                Text("${entry.stationNumber} · ${OperationNames.display(context, entry.operationName)} · ${entry.piecesProduced} pcs", style: ThemeTokens.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${entry.efficiencyPct.toStringAsFixed(0)}%", style: ThemeTokens.headingMedium.copyWith(fontSize: 14, color: color)),
              Text(entry.classification, style: ThemeTokens.labelSmall.copyWith(color: color, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
