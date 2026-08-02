import 'package:flutter/material.dart';
import '../../components/custom_toast.dart';
import '../../l10n/app_localizations.dart';
import '../../models/production_entry.dart';
import '../../models/roster_entry.dart';
import '../../models/station.dart';
import '../../services/allocation_api_service.dart';
import '../../services/attendance_api_service.dart';
import '../../services/production_entry_api_service.dart';
import '../../services/station_api_service.dart';
import '../../utils/employee_names.dart';
import '../../utils/error_messages.dart';
import '../../utils/operation_names.dart';
import '../../utils/theme_tokens.dart';
import 'employee_slots_screen.dart';
import 'operations_widgets.dart';

/// Supervisor's entry point for logging production: everyone present today, with each
/// person's running total for the day.
///
/// Only people with an attendance record are listed - production cannot be logged for
/// someone who did not come in. The sync button pulls fresh punches from HRMS; if HRMS
/// is unreachable the error is surfaced rather than silently falling back to a stale or
/// wider list, because quietly showing absent people invites wrong data.
class ProductionEntryScreen extends StatefulWidget {
  const ProductionEntryScreen({super.key});

  @override
  State<ProductionEntryScreen> createState() => _ProductionEntryScreenState();
}

class _ProductionEntryScreenState extends State<ProductionEntryScreen> {
  final _allocationApiService = AllocationApiService();
  final _stationApiService = StationApiService();
  final _entryApiService = ProductionEntryApiService();
  final _attendanceApiService = AttendanceApiService();
  final _searchController = TextEditingController();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  List<RosterEntry> _roster = [];
  List<Station> _stations = [];
  List<ProductionEntry> _entries = [];
  String _query = '';

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
      final date = formatIsoDate(_date);
      final results = await Future.wait([
        _allocationApiService.rosterForDate(date, forceRefresh: forceRefresh),
        _stationApiService.listStations(forceRefresh: forceRefresh),
        _entryApiService.listForDate(date, forceRefresh: forceRefresh),
      ]);
      if (!mounted) return;
      setState(() {
        _roster = results[0] as List<RosterEntry>;
        _stations = results[1] as List<Station>;
        _entries = results[2] as List<ProductionEntry>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ErrorMessages.translate(context, e);
        _isLoading = false;
      });
    }
  }

  /// Pulls fresh attendance from HRMS. Only as many days back as the chosen date needs,
  /// so looking at today does not drag ninety days of history across the network.
  Future<void> _syncAttendance() async {
    setState(() => _isSyncing = true);
    try {
      final days = DateTime.now().difference(_date).inDays.clamp(0, 366) + 1;
      final result = await _attendanceApiService.syncHistory(days: days);
      if (!mounted) return;
      CustomToast.show(context, L10n.of(context).syncedRecords(result.recordsSynced));
      await _load(forceRefresh: true);
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, ErrorMessages.translate(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _openEmployee(RosterEntry entry) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EmployeeSlotsScreen(
          employeeId: entry.employeeId,
          employeeName: entry.employeeName,
          date: _date,
          stations: _stations,
        ),
      ),
    );
    if (changed == true) _load(forceRefresh: true);
  }

  List<RosterEntry> get _filtered {
    final sorted = [..._roster]..sort((a, b) => a.employeeName.compareTo(b.employeeName));
    if (_query.isEmpty) return sorted;
    return sorted.where((e) {
      final telugu = EmployeeNames.display(context, e.employeeName).toLowerCase();
      return e.employeeName.toLowerCase().contains(_query) ||
          telugu.contains(_query) ||
          (e.employeeCode?.toLowerCase().contains(_query) ?? false);
    }).toList();
  }

  int _piecesFor(int employeeId) => _entries
      .where((e) => e.employeeId == employeeId)
      .fold<int>(0, (sum, e) => sum + e.piecesProduced);

  @override
  Widget build(BuildContext context) {
    final t = L10n.of(context);
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(t.logProduction, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        backgroundColor: ThemeTokens.background,
        actions: [
          IconButton(
            tooltip: t.syncAttendance,
            onPressed: _isSyncing ? null : _syncAttendance,
            icon: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: ThemeTokens.primary))
                : const Icon(Icons.sync_rounded, color: ThemeTokens.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: OpsDatePickerBar(date: _date, onChanged: (d) { setState(() => _date = d); _load(); }),
          ),
          if (!_isLoading && _errorMessage == null && _roster.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchController,
                style: ThemeTokens.inputText,
                decoration: InputDecoration(
                  hintText: t.searchHint,
                  hintStyle: ThemeTokens.hintText,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: ThemeTokens.textLight),
                  filled: true,
                  fillColor: ThemeTokens.surfaceSolid,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  border: _border(),
                  enabledBorder: _border(),
                  focusedBorder: _border(focused: true),
                ),
              ),
            ),
          Expanded(child: _buildBody(t)),
        ],
      ),
    );
  }

  OutlineInputBorder _border({bool focused = false}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        borderSide: BorderSide(
          color: focused ? ThemeTokens.primary : ThemeTokens.hairline,
          width: focused ? 1.5 : 1,
        ),
      );

  Widget _buildBody(L10n t) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));

    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: t.couldnTLoadAttendance,
        body: _errorMessage!,
      );
    }

    if (_roster.isEmpty) {
      return OpsStateMessage(
        icon: Icons.person_off_outlined,
        title: t.nobodyPresentToday,
        body: t.tapSyncToPullAttendance,
      );
    }

    final list = _filtered;
    if (list.isEmpty) {
      return OpsStateMessage(icon: Icons.search_off_rounded, title: t.noResults, body: '');
    }

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final entry = list[index];
          return _PresentEmployeeCard(
            entry: entry,
            pieces: _piecesFor(entry.employeeId),
            onTap: () => _openEmployee(entry),
          );
        },
      ),
    );
  }
}

/// One present operator, with their running total for the day.
class _PresentEmployeeCard extends StatelessWidget {
  final RosterEntry entry;
  final int pieces;
  final VoidCallback onTap;

  const _PresentEmployeeCard({required this.entry, required this.pieces, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasWork = pieces > 0;
    final station = entry.stationNumber == null
        ? null
        : '${entry.stationNumber} · ${OperationNames.display(context, entry.operationName ?? '')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: ThemeTokens.hairline),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EmployeeNames.display(context, entry.employeeName),
                      style: ThemeTokens.bodyLarge.copyWith(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      station ?? (entry.employeeCode ?? ''),
                      style: ThemeTokens.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$pieces',
                    style: ThemeTokens.headingMedium.copyWith(
                      fontSize: 19,
                      color: hasWork ? ThemeTokens.primary : ThemeTokens.textLight,
                    ),
                  ),
                  Text(L10n.of(context).pieces.toLowerCase(), style: ThemeTokens.caption.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(width: 6.0),
              const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
