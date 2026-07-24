import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/attendance_widgets.dart';
import '../components/custom_toast.dart';
import '../models/attendance_history_record.dart';
import '../services/attendance_api_service.dart';
import '../utils/theme_tokens.dart';

const _monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

/// Monthly Attendance - pick a month and review the whole period from local
/// synced history. A SYNC action backfills months that haven't been pulled yet.
class MonthlyAttendanceScreen extends StatefulWidget {
  const MonthlyAttendanceScreen({super.key});

  @override
  State<MonthlyAttendanceScreen> createState() => _MonthlyAttendanceScreenState();
}

class _MonthlyAttendanceScreenState extends State<MonthlyAttendanceScreen> {
  final AttendanceApiService _apiService = AttendanceApiService();
  final TextEditingController _searchController = TextEditingController();

  late DateTime _month; // first day of selected month
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  List<AttendanceHistoryRecord> _records = [];
  String _query = "";

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _searchController.addListener(() => setState(() => _query = _searchController.text.trim().toLowerCase()));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime get _monthEnd => DateTime(_month.year, _month.month + 1, 0);

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final records = await _apiService.getHistoryRange(_month, _monthEnd);
      if (!mounted) return;
      setState(() {
        _records = records;
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

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    try {
      final days = (DateTime.now().difference(_month).inDays + 2).clamp(1, 366);
      final result = await _apiService.syncHistory(days: days);
      if (!mounted) return;
      CustomToast.show(context, "Synced ${result.recordsSynced} record(s)");
      await _load();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _pickMonth() async {
    int year = _month.year;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: ThemeTokens.surfaceSolid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: () => setDialogState(() => year--)),
                        Text("$year", style: ThemeTokens.headingMedium.copyWith(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: year >= DateTime.now().year ? null : () => setDialogState(() => year++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.0,
                      children: List.generate(12, (i) {
                        final isFuture = DateTime(year, i + 1, 1).isAfter(DateTime(DateTime.now().year, DateTime.now().month, 1));
                        final selected = year == _month.year && i + 1 == _month.month;
                        return Material(
                          color: selected ? ThemeTokens.primary : ThemeTokens.surfaceSunken,
                          borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                            onTap: isFuture ? null : () => Navigator.of(dialogContext).pop(DateTime(year, i + 1, 1)),
                            child: Center(
                              child: Text(
                                _monthNames[i].substring(0, 3),
                                style: ThemeTokens.labelSmall.copyWith(
                                  color: isFuture ? ThemeTokens.textMuted : (selected ? Colors.white : ThemeTokens.textPrimary),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked != null && picked != _month) {
      setState(() => _month = picked);
      _load();
    }
  }

  List<AttendanceHistoryRecord> get _filtered {
    if (_query.isEmpty) return _records;
    return _records.where((r) => r.employeeName.toLowerCase().contains(_query) || r.employeeCode.toLowerCase().contains(_query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text("Monthly Attendance", style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        actions: [
          IconButton(
            tooltip: "Sync this month",
            onPressed: _isSyncing ? null : _sync,
            icon: _isSyncing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary))
                : const Icon(Icons.sync_rounded, color: ThemeTokens.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              children: [
                _MonthBar(label: "${_monthNames[_month.month - 1]} ${_month.year}", onTap: _pickMonth),
                const SizedBox(height: 14.0),
                _MonthSummary(records: _records),
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
    if (_errorMessage != null) {
      return AttendanceMessage(
        icon: Icons.wifi_off_rounded,
        title: "Couldn't load this month",
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _load)),
      );
    }

    final list = _filtered;
    if (_records.isEmpty || list.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
        children: [
          Text(
            _records.isEmpty
                ? "No synced records for ${_monthNames[_month.month - 1]}. Tap the sync icon to pull this month from the device."
                : "No one matches \"${_searchController.text.trim()}\".",
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
          leading: "${r.workDate.day.toString().padLeft(2, '0')}/${r.workDate.month.toString().padLeft(2, '0')}",
          name: r.employeeName,
          subtitle: r.employeeCode,
          times: "${r.firstIn ?? '—'} → ${r.lastOut ?? '—'}",
          status: r.status ?? "—",
          late: r.late,
        );
      },
    );
  }
}

class _MonthBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MonthBar({required this.label, required this.onTap});

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
            Icon(Icons.calendar_month_rounded, size: 19, color: ThemeTokens.primary),
            const SizedBox(width: 12.0),
            Expanded(child: Text(label, style: ThemeTokens.bodyLarge.copyWith(fontSize: 14.5))),
            Text("CHANGE", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.primary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final List<AttendanceHistoryRecord> records;
  const _MonthSummary({required this.records});

  @override
  Widget build(BuildContext context) {
    final lateCount = records.where((r) => r.late).length;
    final employees = records.map((r) => r.employeeCode).toSet().length;
    return SummaryPanel(
      eyebrow: "This month",
      figures: [
        (value: "${records.length}", label: "Records", color: ThemeTokens.primary),
        (value: "$employees", label: "Employees", color: ThemeTokens.success),
        (value: "$lateCount", label: "Late", color: ThemeTokens.warning),
      ],
    );
  }
}
