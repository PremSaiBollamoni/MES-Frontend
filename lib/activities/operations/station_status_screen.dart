import 'package:flutter/material.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../components/app_button.dart';
import '../../models/station_status.dart';
import '../../services/station_status_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';

/// Read-only manned/unmanned board for the current shift date - highlights
/// UNMANNED stations, and flags the one that's both unmanned and the current
/// SAM bottleneck (§9) as critical.
class StationStatusScreen extends StatefulWidget {
  const StationStatusScreen({super.key});

  @override
  State<StationStatusScreen> createState() => _StationStatusScreenState();
}

class _StationStatusScreenState extends State<StationStatusScreen> with SingleTickerProviderStateMixin {
  final StationStatusApiService _apiService = StationStatusApiService();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  List<StationStatus> _statuses = [];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final statuses = await _apiService.getStatus(formatIsoDate(_date), forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _statuses = statuses;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(L10n.of(context).stationStatus, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        bottom: (!_isLoading && _errorMessage == null && _statuses.isNotEmpty)
            ? TabBar(
                controller: _tabController,
                labelColor: ThemeTokens.primary,
                unselectedLabelColor: ThemeTokens.textLight,
                indicatorColor: ThemeTokens.primary,
                tabs: [
                  Tab(text: "Needs Attention (${_needsAttention.length})"),
                  Tab(text: "Manned (${_manned.length})"),
                ],
              )
            : null,
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

  List<StationStatus> get _needsAttention {
    final list = _statuses.where((s) => s.status == 'UNALLOCATED' || s.status == 'UNMANNED').toList();
    list.sort((a, b) => (b.critical ? 1 : 0) - (a.critical ? 1 : 0));
    return list;
  }

  List<StationStatus> get _manned => _statuses.where((s) => s.status == 'MANNED').toList();

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: L10n.of(context).couldnTLoadStationStatus,
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
      );
    }
    if (_statuses.isEmpty) {
      return OpsStateMessage(
        icon: Icons.dashboard_customize_outlined,
        title: L10n.of(context).noStationsFound,
        body: L10n.of(context).setUpStationsFirstThen,
      );
    }
    return TabBarView(
      controller: _tabController,
      children: [
        _buildList(_needsAttention, Icons.check_circle_outline, L10n.of(context).allStationsCovered, L10n.of(context).noUnallocatedOrUnmannedStations),
        _buildList(_manned, Icons.groups_outlined, L10n.of(context).noMannedStations, L10n.of(context).assignOperatorsToStationsTo),
      ],
    );
  }

  Widget _buildList(List<StationStatus> items, IconData emptyIcon, String emptyTitle, String emptyBody) {
    if (items.isEmpty) {
      return RefreshIndicator(
        color: ThemeTokens.primary,
        onRefresh: () => _load(forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          children: [
            const SizedBox(height: 48),
            OpsStateMessage(icon: emptyIcon, title: emptyTitle, body: emptyBody),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemCount: items.length,
        itemBuilder: (context, index) => _StatusRow(status: items[index]),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final StationStatus status;
  const _StatusRow({required this.status});

  Color get _statusColor {
    if (status.critical) return ThemeTokens.error;
    if (status.status == 'MANNED') return ThemeTokens.success;
    if (status.status == 'UNMANNED') return ThemeTokens.warning;
    return ThemeTokens.textLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        border: Border.all(color: status.critical ? ThemeTokens.error.withValues(alpha: 0.5) : ThemeTokens.hairline),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: _statusColor),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(OperationNames.display(context, status.operationName), style: ThemeTokens.headingMedium.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis)),
                    if (status.critical) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                        decoration: BoxDecoration(color: ThemeTokens.error.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                        child: Text("BOTTLENECK", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.error, fontSize: 9)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  "${status.stationNumber} · ${status.zone} · SAM ${status.sam}${status.allocatedEmployeeName != null ? ' · ${status.allocatedEmployeeName}' : ''}",
                  style: ThemeTokens.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(status.status, style: ThemeTokens.labelSmall.copyWith(color: _statusColor, fontSize: 11)),
        ],
      ),
    );
  }
}
