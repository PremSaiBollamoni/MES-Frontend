import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/attendance_widgets.dart';
import '../models/attendance.dart';
import '../services/attendance_api_service.dart';
import '../utils/theme_tokens.dart';

/// Live Attendance - today's punches and the present / absent / late split.
class LiveAttendanceScreen extends StatefulWidget {
  const LiveAttendanceScreen({super.key});

  @override
  State<LiveAttendanceScreen> createState() => _LiveAttendanceScreenState();
}

class _LiveAttendanceScreenState extends State<LiveAttendanceScreen> {
  final AttendanceApiService _apiService = AttendanceApiService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _notConfigured = false;
  String? _errorMessage;
  LiveAttendanceStatus? _live;
  List<DailyAttendanceRecord> _daily = [];
  String _query = "";

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

  List<DailyAttendanceRecord> get _filtered {
    if (_query.isEmpty) return _daily;
    return _daily.where((r) => r.employeeName.toLowerCase().contains(_query) || r.employeeCode.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text("Live Attendance", style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_notConfigured) {
      return const AttendanceMessage(
        icon: Icons.link_off_rounded,
        title: "HRMS not connected yet",
        body: "The biometric attendance portal hasn't been configured on the server yet.",
      );
    }
    if (_errorMessage != null) {
      return AttendanceMessage(
        icon: Icons.wifi_off_rounded,
        title: "Couldn't load attendance",
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _load)),
      );
    }

    final live = _live!;
    final list = _filtered;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            children: [
              SummaryPanel(
                eyebrow: "Live · as of ${_formatTime(live.asOf)} · ${live.totalEmployees} total",
                figures: [
                  (value: "${live.presentCount}", label: "Present", color: ThemeTokens.success),
                  (value: "${live.absentCount}", label: "Absent", color: ThemeTokens.error),
                  (value: "${live.lateCount}", label: "Late", color: ThemeTokens.warning),
                ],
              ),
              const SizedBox(height: 16.0),
              AttendanceSearchField(controller: _searchController),
              const SizedBox(height: 4.0),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: ThemeTokens.primary,
            onRefresh: _load,
            child: (_daily.isEmpty || list.isEmpty)
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                    children: [
                      Text(
                        _daily.isEmpty ? "No punches recorded yet today." : "No one matches \"${_searchController.text.trim()}\".",
                        style: ThemeTokens.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final r = list[index];
                      return AttendanceRow(
                        name: r.employeeName,
                        subtitle: [r.employeeCode, if (r.departmentName != null) r.departmentName!].join('  ·  '),
                        times: "${_formatTime(r.firstIn)} → ${_formatTime(r.lastOut)}",
                        status: r.status,
                        late: r.isLate,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
