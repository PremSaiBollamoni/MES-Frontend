import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/custom_toast.dart';
import '../../models/employee_day_activity.dart';
import '../../models/production_entry.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../models/tracking_session.dart';
import '../../services/allocation_api_service.dart';
import '../../services/production_entry_api_service.dart';
import '../../services/station_api_service.dart';
import '../../services/tracking_session_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'employee_activity_card.dart';
import 'employee_day_detail_screen.dart';
import 'log_production_entry_dialog.dart';
import 'operations_widgets.dart';

/// Supervisor's full-day production view across every operator, with the
/// ability to log a new entry on an operator's behalf.
class ProductionEntryScreen extends StatefulWidget {
  const ProductionEntryScreen({super.key});

  @override
  State<ProductionEntryScreen> createState() => _ProductionEntryScreenState();
}

class _ProductionEntryScreenState extends State<ProductionEntryScreen> {
  final ProductionEntryApiService _apiService = ProductionEntryApiService();
  final AllocationApiService _allocationApiService = AllocationApiService();
  final StationApiService _stationApiService = StationApiService();
  final TrackingSessionApiService _trackingApiService = TrackingSessionApiService();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  List<ProductionEntry> _entries = [];
  List<RosterEntry> _roster = [];
  List<Station> _stations = [];
  List<TrackingSession> _activeSessions = [];

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
      final results = await Future.wait([
        _apiService.listForDate(formatIsoDate(_date)),
        _allocationApiService.rosterForDate(formatIsoDate(_date)),
        _stationApiService.listStations(),
        _trackingApiService.listForDate(formatIsoDate(_date)),
      ]);
      if (!mounted) return;
      setState(() {
        _entries = results[0] as List<ProductionEntry>;
        _roster = results[1] as List<RosterEntry>;
        _stations = results[2] as List<Station>;
        _activeSessions = (results[3] as List<TrackingSession>).where((s) => s.status == 'ACTIVE').toList();
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

  Future<void> _openLogDialog() async {
    if (_roster.isEmpty || _stations.isEmpty) {
      CustomToast.show(context, "No operators present or stations available", isError: true);
      return;
    }
    await showDialog(
      context: context,
      builder: (_) => LogProductionEntryDialog(
        operators: _roster,
        stations: _stations,
        onSubmit: (employeeId, stationId, pieces, minutes) async {
          final entry = await _apiService.log(LogProductionEntryRequest(
            employeeId: employeeId,
            stationId: stationId,
            shiftDate: formatIsoDate(_date),
            piecesProduced: pieces,
            timeOnMachineMinutes: minutes,
          ));
          if (mounted) {
            CustomToast.show(context, "Logged: ${entry.efficiencyPct.toStringAsFixed(0)}% efficiency (${entry.classification})");
          }
        },
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text("Production Entry", style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
      floatingActionButton: FloatingActionButton(
        heroTag: "production_entry_fab",
        onPressed: _isLoading ? null : _openLogDialog,
        backgroundColor: ThemeTokens.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
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
        title: "Couldn't load production entries",
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _load)),
      );
    }
    final byEmployee = EmployeeDayActivity.groupByEmployee(entries: _entries, activeSessions: _activeSessions);
    if (byEmployee.isEmpty) {
      return const OpsStateMessage(
        icon: Icons.speed_outlined,
        title: "No activity logged yet",
        body: "Tap + to log pieces produced on behalf of an operator, or start tracking from Operator Allocation.",
      );
    }
    final activities = EmployeeDayActivity.sorted(byEmployee);
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return EmployeeActivityCard(
            activity: activity,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => EmployeeDayDetailScreen(activity: activity, date: _date),
              ));
              _load();
            },
          );
        },
      ),
    );
  }
}
