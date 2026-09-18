import 'package:flutter/material.dart';
import '../utils/operation_names.dart';
import '../l10n/app_localizations.dart';
import '../components/app_button.dart';
import '../models/station.dart';
import '../services/station_api_service.dart';
import '../utils/theme_tokens.dart';
import 'station_form_screen.dart';

/// Station / Operation Bulletin (SAM sheet) - the IE / SAM Analyst's master
/// data screen. Every wage, efficiency, and bottleneck feature downstream
/// reads from this list.
class StationListScreen extends StatefulWidget {
  const StationListScreen({super.key});

  @override
  State<StationListScreen> createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  final StationApiService _apiService = StationApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Station> _stations = [];
  String _query = "";
  String _zoneFilter = "ALL"; // ALL, S1, S2

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim().toLowerCase()));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final stations = await _apiService.listStations(forceRefresh: forceRefresh);
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

  Future<void> _openForm({Station? existing}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StationFormScreen(existing: existing)),
    );
    if (changed == true) _load();
  }

  List<Station> get _filtered {
    var list = _stations;
    if (_zoneFilter != "ALL") list = list.where((s) => s.zone == _zoneFilter).toList();
    if (_query.isNotEmpty) {
      list = list
          .where((s) => s.operationName.toLowerCase().contains(_query) || s.stationNumber.toLowerCase().contains(_query))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      floatingActionButton: FloatingActionButton(
        heroTag: "station_list_fab",
        onPressed: () => _openForm(),
        backgroundColor: ThemeTokens.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isLoading && _errorMessage == null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: _SummaryStrip(stations: _stations),
              ),
              const SizedBox(height: 12.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: _searchController,
                  style: ThemeTokens.inputText,
                  decoration: InputDecoration(
                    hintText: L10n.of(context).searchByStationOrOperation,
                    hintStyle: ThemeTokens.hintText,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ThemeTokens.textLight),
                    filled: true,
                    fillColor: ThemeTokens.surfaceSunken,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                      borderSide: const BorderSide(color: ThemeTokens.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              _ZoneFilterBar(selected: _zoneFilter, onChanged: (z) => setState(() => _zoneFilter = z)),
            ],
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: ThemeTokens.error, size: 40),
              const SizedBox(height: 12.0),
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
            ],
          ),
        ),
      );
    }

    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _stations.isEmpty ? "No stations yet." : "No station matches \"${_searchController.text.trim()}\".",
            style: ThemeTokens.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
        itemCount: list.length,
        itemBuilder: (context, index) => _StationRow(station: list[index], onTap: () => _openForm(existing: list[index])),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final List<Station> stations;
  const _SummaryStrip({required this.stations});

  @override
  Widget build(BuildContext context) {
    final s1 = stations.where((s) => s.zone == 'S1').length;
    final s2 = stations.where((s) => s.zone == 'S2').length;
    final totalSam = stations.fold<double>(0, (sum, s) => sum + s.sam);

    Widget stat(String label, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: ThemeTokens.headingLarge.copyWith(fontSize: 20)),
            const SizedBox(height: 2.0),
            Text(label.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 10)),
          ],
        ),
      );
    }

    return Row(
      children: [
        stat("Stations", "${stations.length}"),
        stat("S1", "$s1"),
        stat("S2", "$s2"),
        stat(L10n.of(context).totalSam, totalSam.toStringAsFixed(1)),
      ],
    );
  }
}

class _ZoneFilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _ZoneFilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String value, String label) {
      final isSelected = selected == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          onTap: () => onChanged(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSelected ? ThemeTokens.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
              border: Border.all(color: isSelected ? ThemeTokens.ink : ThemeTokens.hairline),
            ),
            child: Text(
              label,
              style: ThemeTokens.labelSmall.copyWith(color: isSelected ? ThemeTokens.onInk : ThemeTokens.textSecondary, fontSize: 11),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(children: [chip("ALL", L10n.of(context).allZones), chip("S1", L10n.of(context).s1SubAssembly), chip("S2", L10n.of(context).s2FullGarment)]),
    );
  }
}

class _StationRow extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  const _StationRow({required this.station, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ThemeTokens.hairline))),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ThemeTokens.background,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  border: Border.all(color: ThemeTokens.hairline),
                ),
                alignment: Alignment.center,
                child: Text(
                  station.stationNumber.replaceAll('STATION-', ''),
                  style: ThemeTokens.headingMedium.copyWith(fontSize: 14, color: station.active ? ThemeTokens.primary : ThemeTokens.textLight),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(OperationNames.display(context, station.operationName), style: ThemeTokens.headingMedium.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text(
                      "${station.zone}  ·  SAM ${station.sam}  ·  ${station.targetPiecesPerDay} pcs/day",
                      style: ThemeTokens.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${station.ratePerPiece.toStringAsFixed(2)}/pc", style: ThemeTokens.caption),
                  const SizedBox(height: 2.0),
                  Text(
                    "₹${station.targetWagePerDay.toStringAsFixed(0)}/day/op",
                    style: ThemeTokens.labelSmall.copyWith(fontSize: 10, color: ThemeTokens.success),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
