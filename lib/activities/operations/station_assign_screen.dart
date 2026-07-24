import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/custom_toast.dart';
import '../../models/allocation.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../models/tracking_session.dart';
import '../../services/allocation_api_service.dart';
import '../../services/tracking_session_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'pieces_prompt_dialog.dart';
import 'tracking_session_screen.dart';

/// Fills exactly [Station.operatorCount] seats for one station, then assigns
/// and starts tracking for the whole team as a single action (PALMS §10).
/// Operators already allocated elsewhere are still eligible here - operators
/// can move station-to-station within a shift, allocation isn't fixed for
/// the day.
class StationAssignScreen extends StatefulWidget {
  final Station station;
  final DateTime date;

  const StationAssignScreen({super.key, required this.station, required this.date});

  @override
  State<StationAssignScreen> createState() => _StationAssignScreenState();
}

class _StationAssignScreenState extends State<StationAssignScreen> {
  final AllocationApiService _apiService = AllocationApiService();
  final TrackingSessionApiService _trackingApiService = TrackingSessionApiService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<RosterEntry> _eligible = [];
  final Set<int> _selected = {};

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
      final roster = await _apiService.rosterForDate(formatIsoDate(widget.date));
      if (!mounted) return;
      setState(() {
        _eligible = roster.where((e) => !e.isTracking).toList()
          ..sort((a, b) => a.employeeName.compareTo(b.employeeName));
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

  int get _needed => widget.station.operatorCount;

  void _toggle(int employeeId) {
    setState(() {
      if (_selected.contains(employeeId)) {
        _selected.remove(employeeId);
      } else if (_selected.length < _needed) {
        _selected.add(employeeId);
      }
    });
  }

  Future<void> _assignAndStart() async {
    if (_selected.length != _needed) return;
    setState(() => _isSubmitting = true);
    final shiftDate = formatIsoDate(widget.date);
    try {
      for (final employeeId in _selected) {
        await _apiService.assign(AssignAllocationRequest(
          employeeId: employeeId,
          stationId: widget.station.id,
          shiftDate: shiftDate,
          shift: "GENERAL",
        ));
      }
      if (!mounted) return;
      final piecesIssued = await showPiecesPromptDialog(
        context,
        title: "Start Tracking",
        label: "Pieces issued",
      );
      if (piecesIssued == null) {
        setState(() => _isSubmitting = false);
        return;
      }
      final session = await _trackingApiService.start(StartTrackingRequest(
        employeeIds: _selected.toList(),
        stationId: widget.station.id,
        shiftDate: shiftDate,
        piecesIssued: piecesIssued,
      ));
      if (!mounted) return;
      await _pushTrackingScreen(session);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pushTrackingScreen(TrackingSession session) async {
    await Navigator.of(context).push<TrackingSession>(
      MaterialPageRoute(builder: (_) => TrackingSessionScreen(session: session)),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text("${station.stationNumber} - ${station.operationName}", style: ThemeTokens.headingMedium.copyWith(fontSize: 16))),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selected.length != _needed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _selected.length < _needed
                        ? "Select ${_needed - _selected.length} more operator${_needed - _selected.length == 1 ? '' : 's'}"
                        : "Select $_needed only",
                    style: ThemeTokens.caption,
                  ),
                ),
              AppPrimaryButton(
                label: "Assign & Start Tracking",
                icon: Icons.play_circle_outline_rounded,
                isLoading: _isSubmitting,
                onPressed: _selected.length == _needed ? _assignAndStart : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final station = widget.station;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Row(
          children: [
            _headerStat("Zone", station.zone),
            _headerStat("SAM", station.sam.toStringAsFixed(2)),
            _headerStat("Operators", "$_needed"),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ThemeTokens.labelSmall.copyWith(fontSize: 10)),
          const SizedBox(height: 4.0),
          Text(value, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: "Couldn't load operators",
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _load)),
      );
    }
    if (_eligible.isEmpty) {
      return const OpsStateMessage(
        icon: Icons.person_off_outlined,
        title: "No available operators",
        body: "Every present operator is already tracking elsewhere for this shift date.",
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: _eligible.map(_buildEmployeeRow).toList(),
    );
  }

  Widget _buildEmployeeRow(RosterEntry entry) {
    final isSelected = _selected.contains(entry.employeeId);
    final alreadyHere = entry.stationId == widget.station.id;
    final disabled = !isSelected && _selected.length >= _needed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: isSelected ? ThemeTokens.primary : ThemeTokens.hairline),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: disabled ? null : (_) => _toggle(entry.employeeId),
        activeColor: ThemeTokens.primary,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(entry.employeeName, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5)),
        subtitle: entry.isAssigned
            ? Text(
                alreadyHere ? "Already here" : "Currently at ${entry.stationNumber} - ${entry.operationName}",
                style: ThemeTokens.caption.copyWith(color: alreadyHere ? ThemeTokens.primary : ThemeTokens.textLight),
              )
            : Text("Unassigned", style: ThemeTokens.caption),
      ),
    );
  }
}
