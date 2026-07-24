import 'package:flutter/material.dart';
import '../app_button.dart';
import '../attendance_widgets.dart';
import '../../models/attendance.dart';
import '../../services/attendance_api_service.dart';
import '../../utils/theme_tokens.dart';

/// Production Supervisor dashboard - live attendance is explicitly their PALMS
/// responsibility (§5), so that's the headline here instead of company-wide
/// headcount. Reuses the same attendance widgets as the Attendance module.
class AttendanceDashboard extends StatefulWidget {
  const AttendanceDashboard({super.key});

  @override
  State<AttendanceDashboard> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboard> {
  final AttendanceApiService _apiService = AttendanceApiService();

  bool _isLoading = true;
  bool _notConfigured = false;
  String? _errorMessage;
  LiveAttendanceStatus? _live;
  List<DailyAttendanceRecord> _daily = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _notConfigured = false;
    });
    try {
      final results = await Future.wait([_apiService.getLiveStatus(), _apiService.getDaily()]);
      if (!mounted) return;
      setState(() {
        _live = results[0] as LiveAttendanceStatus;
        _daily = results[1] as List<DailyAttendanceRecord>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll("Exception: ", "");
      setState(() {
        _notConfigured = message.contains("not configured");
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "—";
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return "$hour:$minute ${local.hour >= 12 ? "PM" : "AM"}";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_notConfigured) {
      return const AttendanceMessage(
        icon: Icons.link_off_rounded,
        title: "HRMS not connected yet",
        body: "The biometric attendance portal hasn't been configured on the server yet.",
      );
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
              SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _load)),
            ],
          ),
        ),
      );
    }

    final live = _live!;
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          SummaryPanel(
            eyebrow: "Live · as of ${_formatTime(live.asOf)} · ${live.totalEmployees} total",
            figures: [
              (value: "${live.presentCount}", label: "Present", color: ThemeTokens.success),
              (value: "${live.absentCount}", label: "Absent", color: ThemeTokens.error),
              (value: "${live.lateCount}", label: "Late", color: ThemeTokens.warning),
            ],
          ),
          const SizedBox(height: 28.0),
          Row(
            children: [
              Container(width: 18, height: 2, color: ThemeTokens.primary),
              const SizedBox(width: 10.0),
              Text("TODAY'S ATTENDANCE", style: ThemeTokens.labelSmall),
            ],
          ),
          const SizedBox(height: 8.0),
          if (_daily.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text("No punches recorded yet today.", style: ThemeTokens.bodyMedium),
            )
          else
            ..._daily.take(8).map((r) => AttendanceRow(
                  name: r.employeeName,
                  subtitle: [r.employeeCode, if (r.departmentName != null) r.departmentName!].join('  ·  '),
                  times: "${_formatTime(r.firstIn)} → ${_formatTime(r.lastOut)}",
                  status: r.status,
                  late: r.isLate,
                )),
        ],
      ),
    );
  }
}
