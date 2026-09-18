import 'package:flutter/material.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../app_button.dart';
import '../../models/station.dart';
import '../../services/station_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'ledger_hero.dart';

/// IE / SAM Analyst dashboard - stations, SAM, and the actual PALMS §9 rule
/// ("Highest SAM = Bottleneck") computed live from real station data, not a
/// placeholder. This is the one dashboard that can genuinely answer
/// "what's the bottleneck right now" today, ahead of full production tracking.
class SamDashboard extends StatefulWidget {
  const SamDashboard({super.key});

  @override
  State<SamDashboard> createState() => _SamDashboardState();
}

class _SamDashboardState extends State<SamDashboard> {
  final StationApiService _apiService = StationApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Station> _stations = [];

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
      final stations = await _apiService.listStations();
      if (!mounted) return;
      setState(() {
        _stations = stations;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
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

    if (_stations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(L10n.of(context).noStationsSetUpYet, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }

    final active = _stations.where((s) => s.active).toList();
    final s1Count = active.where((s) => s.zone == 'S1').length;
    final s2Count = active.where((s) => s.zone == 'S2').length;
    final totalSam = active.fold<double>(0, (sum, s) => sum + s.sam);
    final bottleneck = active.reduce((a, b) => b.sam > a.sam ? b : a);
    final ranked = [...active]..sort((a, b) => b.sam.compareTo(a.sam));

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          LedgerHero(
            eyebrow: L10n.of(context).stationsTracked,
            value: "${active.length}",
            stats: [
              (value: totalSam.toStringAsFixed(1), label: L10n.of(context).totalSam),
              (value: "$s1Count", label: "S1"),
              (value: "$s2Count", label: "S2"),
            ],
          ),
          const SizedBox(height: 28.0),
          _BottleneckCallout(station: bottleneck),
          const SizedBox(height: 28.0),
          Row(
            children: [
              Container(width: 18, height: 2, color: ThemeTokens.primary),
              const SizedBox(width: 10.0),
              Text(L10n.of(context).highestSamRanked, style: ThemeTokens.labelSmall),
            ],
          ),
          const SizedBox(height: 8.0),
          ...ranked.take(8).map((s) => _SamRow(station: s)),
        ],
      ),
    );
  }
}

/// PALMS §9: "Highest SAM = Bottleneck". This is a direct, live application of
/// that rule, not a mocked-up card.
class _BottleneckCallout extends StatelessWidget {
  final Station station;
  const _BottleneckCallout({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: ThemeTokens.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall)),
            alignment: Alignment.center,
            child: Icon(Icons.warning_amber_rounded, color: ThemeTokens.error, size: 22),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("BOTTLENECK", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.error, fontSize: 10)),
                const SizedBox(height: 3.0),
                Text(
                  "${station.stationNumber} · ${OperationNames.display(context, station.operationName)}",
                  style: ThemeTokens.headingMedium.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text("SAM ${station.sam}", style: ThemeTokens.headingMedium.copyWith(fontSize: 16, color: ThemeTokens.error)),
        ],
      ),
    );
  }
}

class _SamRow extends StatelessWidget {
  final Station station;
  const _SamRow({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(OperationNames.display(context, station.operationName), style: ThemeTokens.bodyLarge.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2.0),
                Text("${station.stationNumber}  ·  ${station.zone}", style: ThemeTokens.caption),
              ],
            ),
          ),
          Text("SAM ${station.sam}", style: ThemeTokens.headingMedium.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}
