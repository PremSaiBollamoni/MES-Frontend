import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/employee_names.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../components/app_button.dart';
import '../../models/tracking_session.dart';
import '../../services/tracking_session_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'pieces_prompt_dialog.dart';
import 'tracking_stat_tile.dart';

/// Live "operator is working right now" view (PALMS §10). Elapsed time, actual
/// SAM and efficiency are all derived client-side every tick - the backend
/// only stores startedAt/piecesIssued and finalizes the real numbers on stop.
class TrackingSessionScreen extends StatefulWidget {
  final TrackingSession session;

  const TrackingSessionScreen({super.key, required this.session});

  @override
  State<TrackingSessionScreen> createState() => _TrackingSessionScreenState();
}

class _TrackingSessionScreenState extends State<TrackingSessionScreen> {
  final TrackingSessionApiService _apiService = TrackingSessionApiService();
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    // The backend serializes startedAt as a Java LocalDateTime - a naive string with
    // no timezone marker (e.g. "2026-07-25T05:30:00"), representing the server clock
    // (UTC on Render). DateTime.parse would otherwise interpret that as LOCAL time on
    // this device, silently adding the device's UTC offset as bogus elapsed time.
    final raw = widget.session.startedAt;
    final started = DateTime.parse(raw.endsWith('Z') ? raw : "${raw}Z");
    setState(() => _elapsed = DateTime.now().toUtc().difference(started));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double get _elapsedMinutes {
    final seconds = _elapsed.inSeconds;
    return (seconds < 1 ? 1 : seconds) / 60.0;
  }

  double get _actualSam => _elapsedMinutes / widget.session.piecesIssued;

  double get _efficiencyPercent => (widget.session.standardSam / _actualSam) * 100;

  String get _classification {
    final eff = _efficiencyPercent;
    if (eff < 50) return "CRITICAL";
    if (eff < 85) return "LOW";
    if (eff < 100) return "MARGINAL";
    if (eff < 150) return "GOOD";
    return "EXCELLENT";
  }

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return hours > 0 ? "${two(hours)}:${two(minutes)}:${two(seconds)}" : "${two(minutes)}:${two(seconds)}";
  }

  Future<void> _stopTracking() async {
    final piecesCompleted = await showPiecesPromptDialog(
      context,
      title: L10n.of(context).stopTracking,
      label: L10n.of(context).piecesCompleted,
      initialValue: widget.session.piecesIssued,
    );
    if (piecesCompleted == null) return;
    setState(() => _isStopping = true);
    try {
      final stopped = await _apiService.stop(widget.session.id, piecesCompleted: piecesCompleted);
      if (!mounted) return;
      Navigator.of(context).pop(stopped);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isStopping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text(L10n.of(context).liveTracking, style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(EmployeeNames.display(context, session.employeeNames), style: ThemeTokens.headingLarge),
              const SizedBox(height: 4.0),
              Text("${session.stationNumber} · ${OperationNames.display(context, session.operationName)}", style: ThemeTokens.bodyMedium),
              const SizedBox(height: 24.0),
              TrackingStatTile(label: L10n.of(context).elapsedTime, value: _formatElapsed(_elapsed), valueColor: ThemeTokens.primary),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(child: TrackingStatTile(label: L10n.of(context).standardSam, value: session.standardSam.toStringAsFixed(2))),
                  const SizedBox(width: 12.0),
                  Expanded(child: TrackingStatTile(label: L10n.of(context).actualSam, value: _actualSam.toStringAsFixed(2))),
                ],
              ),
              const SizedBox(height: 12.0),
              TrackingStatTile(
                label: L10n.of(context).efficiency,
                value: "${_efficiencyPercent.toStringAsFixed(0)}% · $_classification",
                valueColor: classificationColor(_classification),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(child: TrackingStatTile(label: L10n.of(context).piecesIssued, value: "${session.piecesIssued}")),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TrackingStatTile(
                      label: session.requiredOperatorCount > 1 ? L10n.of(context).estWagePerOperator : L10n.of(context).estWages,
                      value: session.estimatedWagesPerOperator.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              if (session.requiredOperatorCount > 1) ...[
                const SizedBox(height: 12.0),
                TrackingStatTile(label: L10n.of(context).estWageTeamTotal, value: session.estimatedWages.toStringAsFixed(2)),
              ],
              const SizedBox(height: 32.0),
              AppPrimaryButton(
                label: L10n.of(context).stopTracking,
                onPressed: _stopTracking,
                isLoading: _isStopping,
                icon: Icons.stop_rounded,
                color: ThemeTokens.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
