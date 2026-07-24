import 'dart:async';
import 'package:flutter/material.dart';
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
    final started = DateTime.parse(widget.session.startedAt);
    setState(() => _elapsed = DateTime.now().difference(started));
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
      title: "Stop Tracking",
      label: "Pieces completed",
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
      appBar: AppBar(title: Text("Live Tracking", style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.employeeNames, style: ThemeTokens.headingLarge),
              const SizedBox(height: 4.0),
              Text("${session.stationNumber} · ${session.operationName}", style: ThemeTokens.bodyMedium),
              const SizedBox(height: 24.0),
              TrackingStatTile(label: "Elapsed Time", value: _formatElapsed(_elapsed), valueColor: ThemeTokens.primary),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(child: TrackingStatTile(label: "Standard SAM", value: session.standardSam.toStringAsFixed(2))),
                  const SizedBox(width: 12.0),
                  Expanded(child: TrackingStatTile(label: "Actual SAM", value: _actualSam.toStringAsFixed(2))),
                ],
              ),
              const SizedBox(height: 12.0),
              TrackingStatTile(
                label: "Efficiency",
                value: "${_efficiencyPercent.toStringAsFixed(0)}% · $_classification",
                valueColor: classificationColor(_classification),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(child: TrackingStatTile(label: "Pieces Issued", value: "${session.piecesIssued}")),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: TrackingStatTile(
                      label: session.requiredOperatorCount > 1 ? "Est. Wage (per operator)" : "Est. Wages",
                      value: session.estimatedWagesPerOperator.toStringAsFixed(2),
                    ),
                  ),
                ],
              ),
              if (session.requiredOperatorCount > 1) ...[
                const SizedBox(height: 12.0),
                TrackingStatTile(label: "Est. Wage (team total)", value: session.estimatedWages.toStringAsFixed(2)),
              ],
              const SizedBox(height: 32.0),
              AppPrimaryButton(
                label: "Stop Tracking",
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
