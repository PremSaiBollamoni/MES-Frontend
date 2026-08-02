import 'package:flutter/material.dart';
import '../utils/employee_names.dart';
import '../l10n/app_localizations.dart';
import '../components/app_button.dart';
import '../components/attendance_widgets.dart';
import '../models/attendance.dart';
import '../services/attendance_api_service.dart';
import '../utils/theme_tokens.dart';

/// Daily Attendance - pick any past date and see that day's attendance pulled
/// from HRMS.
class DailyAttendanceScreen extends StatefulWidget {
  const DailyAttendanceScreen({super.key});

  @override
  State<DailyAttendanceScreen> createState() => _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState extends State<DailyAttendanceScreen> {
  final AttendanceApiService _apiService = AttendanceApiService();
  final TextEditingController _searchController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  bool _notConfigured = false;
  String? _errorMessage;
  List<DailyAttendanceRecord> _records = [];
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
      final records = await _apiService.getDaily(date: _date);
      if (!mounted) return;
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceAll("Exception: ", "");
      setState(() {
        _notConfigured = message.contains(L10n.of(context).notConfigured);
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
      _load();
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return "—";
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    return "$hour:$minute ${local.hour >= 12 ? "PM" : "AM"}";
  }

  String _longDate(DateTime d) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  List<DailyAttendanceRecord> get _filtered {
    if (_query.isEmpty) return _records;
    return _records.where((r) => r.employeeName.toLowerCase().contains(_query) || r.employeeCode.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text(L10n.of(context).dailyAttendance, style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              children: [
                _DatePickerBar(label: _longDate(_date), onTap: _pickDate),
                const SizedBox(height: 14.0),
                AttendanceSearchField(controller: _searchController),
                const SizedBox(height: 4.0),
              ],
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_notConfigured) {
      return AttendanceMessage(
        icon: Icons.link_off_rounded,
        title: L10n.of(context).hrmsNotConnectedYet,
        body: L10n.of(context).theBiometricAttendancePortalHasn,
      );
    }
    if (_errorMessage != null) {
      return AttendanceMessage(
        icon: Icons.wifi_off_rounded,
        title: L10n.of(context).couldnTLoadThatDay,
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
      );
    }

    final list = _filtered;
    if (_records.isEmpty || list.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
        children: [
          Text(
            _records.isEmpty ? "No attendance recorded on ${_longDate(_date)}." : "No one matches \"${_searchController.text.trim()}\".",
            style: ThemeTokens.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final r = list[index];
        return AttendanceRow(
          name: EmployeeNames.display(context, r.employeeName),
          subtitle: [r.employeeCode, if (r.departmentName != null) r.departmentName!].join('  ·  '),
          times: "${_formatTime(r.firstIn)} → ${_formatTime(r.lastOut)}",
          status: r.status,
          late: r.isLate,
        );
      },
    );
  }
}

/// A tappable pill showing the selected date, opening the date picker.
class _DatePickerBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DatePickerBar({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Row(
          children: [
            Icon(Icons.event_rounded, size: 19, color: ThemeTokens.primary),
            const SizedBox(width: 12.0),
            Expanded(child: Text(label, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5))),
            Text("CHANGE", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.primary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
