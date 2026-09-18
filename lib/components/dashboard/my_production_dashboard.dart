import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production_entry.dart';
import '../../services/production_entry_api_service.dart';
import '../../utils/theme_tokens.dart';
import '../app_button.dart';
import 'ledger_hero.dart';
import 'my_production_day_list.dart';
import 'my_production_grouping.dart';

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
      // 31 days back guarantees full coverage of the current calendar month no matter which
      // day it is (the longest month is 31 days); the result is then filtered to just this
      // month below, so the extra spillover from the tail end of last month never surfaces.
      final entries = await _apiService.myEntries(days: 31);
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
    final now = DateTime.now();
    final month = thisMonthsEntries(_entries, now);

    if (month.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(L10n.of(context).noProductionEntriesLoggedFor, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }

    final totalPieces = month.fold<int>(0, (sum, e) => sum + e.piecesProduced);
    final totalWages = month.fold<double>(0, (sum, e) => sum + e.wagesEarned);
    final avgEfficiency = month.fold<double>(0, (sum, e) => sum + e.efficiencyPct) / month.length;
    final today = todaysEntries(month, now);
    final todayWages = today.fold<double>(0, (sum, e) => sum + e.wagesEarned);
    final todayPieces = today.fold<int>(0, (sum, e) => sum + e.piecesProduced);
    final days = groupByDay(month);

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          // Today first - the single number an operator actually wants at a glance is
          // "what have I earned so far today", not a 30-day average.
          _TodayCard(pieces: todayPieces, wages: todayWages, entryCount: today.length),
          const SizedBox(height: 16.0),
          LedgerHero(
            eyebrow: "${L10n.of(context).piecesThisMonth} — ${_monthLabel(context, now)}",
            value: "$totalPieces",
            stats: [
              (value: "₹${totalWages.toStringAsFixed(0)}", label: L10n.of(context).earnedThisMonth),
              (value: "${avgEfficiency.toStringAsFixed(0)}%", label: L10n.of(context).avgEfficiency),
              (value: "${month.length}", label: L10n.of(context).shiftsLogged),
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
          MyProductionDayList(days: days),
        ],
      ),
    );
  }
}

/// "August 2026" in whichever language is active, rather than a hand-rolled English-only
/// month list that would silently break Telugu parity.
String _monthLabel(BuildContext context, DateTime date) =>
    DateFormat.yMMMM(Localizations.localeOf(context).languageCode).format(date);

/// The one figure an operator actually checks mid-shift: what have I made today.
class _TodayCard extends StatelessWidget {
  final int pieces;
  final double wages;
  final int entryCount;
  const _TodayCard({required this.pieces, required this.wages, required this.entryCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      decoration: BoxDecoration(
        color: ThemeTokens.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY', style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.success)),
                const SizedBox(height: 4.0),
                Text('₹${wages.toStringAsFixed(0)}',
                    style: ThemeTokens.headingDisplay
                        .copyWith(color: ThemeTokens.success, fontSize: 34)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$pieces', style: ThemeTokens.headingMedium.copyWith(fontSize: 20)),
              Text('pieces', style: ThemeTokens.caption),
              const SizedBox(height: 6.0),
              Text('$entryCount ${entryCount == 1 ? "entry" : "entries"}',
                  style: ThemeTokens.caption.copyWith(fontSize: 10.5)),
            ],
          ),
        ],
      ),
    );
  }
}
