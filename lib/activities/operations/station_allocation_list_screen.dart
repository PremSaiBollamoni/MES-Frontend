import 'package:flutter/material.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../components/app_button.dart';
import '../../components/custom_toast.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../services/allocation_api_service.dart';
import '../../services/attendance_api_service.dart';
import '../../services/station_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'station_assign_screen.dart';

/// Station-first entry point for Operator Allocation (PALMS §10) - the
/// Supervisor picks a station first, then fills its seats, instead of
/// picking an employee first and hunting for a station.
class StationAllocationListScreen extends StatefulWidget {
  const StationAllocationListScreen({super.key});

  @override
  State<StationAllocationListScreen> createState() => _StationAllocationListScreenState();
}

class _StationAllocationListScreenState extends State<StationAllocationListScreen> {
  final AllocationApiService _apiService = AllocationApiService();
  final StationApiService _stationApiService = StationApiService();
  final AttendanceApiService _attendanceApiService = AttendanceApiService();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  List<RosterEntry> _roster = [];
  List<Station> _stations = [];

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
      final date = formatIsoDate(_date);
      final results = await Future.wait([
        _apiService.rosterForDate(date, forceRefresh: forceRefresh),
        _stationApiService.listStations(forceRefresh: forceRefresh),
      ]);
      if (!mounted) return;
      setState(() {
        _roster = results[0] as List<RosterEntry>;
        _stations = (results[1] as List<Station>).where((s) => s.active).toList()
          ..sort((a, b) => a.stationNumber.compareTo(b.stationNumber));
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

  /// Local attendance is only pulled from HRMS on-demand (the first time a date is needed)
  /// or via this manual trigger - new punches after that first pull don't show up until
  /// someone re-syncs, so the Supervisor needs a way to force a fresh pull mid-shift.
  Future<void> _syncAttendance() async {
    setState(() => _isSyncing = true);
    try {
      final days = DateTime.now().difference(_date).inDays.clamp(0, 366) + 1;
      final result = await _attendanceApiService.syncHistory(days: days);
      if (!mounted) return;
      CustomToast.show(context, "Synced ${result.recordsSynced} attendance record(s)");
      await _load();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _openStation(Station station) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StationAssignScreen(station: station, date: _date, roster: _roster),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(L10n.of(context).operatorAllocation, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        actions: [
          IconButton(
            tooltip: L10n.of(context).syncAttendanceFromHrms,
            onPressed: _isSyncing ? null : _syncAttendance,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary),
                  )
                : const Icon(Icons.sync_rounded, color: ThemeTokens.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
            child: OpsDatePickerBar(date: _date, onChanged: (d) { setState(() => _date = d); _load(); }),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: L10n.of(context).couldnTLoadStations,
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
      );
    }
    if (_stations.isEmpty) {
      return OpsStateMessage(
        icon: Icons.factory_outlined,
        title: L10n.of(context).noActiveStations,
        body: L10n.of(context).createAStationInStation,
      );
    }
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: _stations.map(_buildStationRow).toList(),
      ),
    );
  }

  Widget _buildStationRow(Station station) {
    final assignedEntries = _roster.where((e) => e.stationId == station.id).toList();
    final trackingCount = assignedEntries.where((e) => e.isTracking).length;
    final assignedCount = assignedEntries.length;
    final needed = station.operatorCount;

    String statusLabel;
    Color statusColor;
    if (trackingCount >= needed) {
      statusLabel = "$trackingCount/$needed tracking";
      statusColor = ThemeTokens.success;
    } else if (assignedCount >= needed) {
      statusLabel = "$assignedCount/$needed assigned, not tracking";
      statusColor = ThemeTokens.warning;
    } else if (assignedCount > 0) {
      statusLabel = "$assignedCount/$needed assigned - needs more";
      statusColor = ThemeTokens.warning;
    } else {
      statusLabel = "0/$needed - needs assignment";
      statusColor = ThemeTokens.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: ThemeTokens.hairline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        onTap: () => _openStation(station),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${station.stationNumber} - ${OperationNames.display(context, station.operationName)}",
                        style: ThemeTokens.bodyLarge.copyWith(fontSize: 15)),
                    const SizedBox(height: 4.0),
                    Text(station.zone, style: ThemeTokens.caption),
                    const SizedBox(height: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                      ),
                      child: Text(statusLabel, style: ThemeTokens.labelSmall.copyWith(color: statusColor, fontSize: 10.5)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
