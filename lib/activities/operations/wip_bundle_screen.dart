import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../components/app_button.dart';
import '../../components/custom_toast.dart';
import '../../models/bundle.dart';
import '../../models/station.dart';
import '../../services/bundle_api_service.dart';
import '../../services/station_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'wip_bundle_dialogs.dart';
import 'wip_bundle_lists.dart';

/// WIP / bundle tracking - create bundles, move them between stations, mark
/// complete, and watch each station's queue depth for alert thresholds.
class WipBundleScreen extends StatefulWidget {
  const WipBundleScreen({super.key});

  @override
  State<WipBundleScreen> createState() => _WipBundleScreenState();
}

class _WipBundleScreenState extends State<WipBundleScreen> with SingleTickerProviderStateMixin {
  final BundleApiService _apiService = BundleApiService();
  final StationApiService _stationApiService = StationApiService();
  late final TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;
  List<Bundle> _bundles = [];
  List<StationWipSummary> _summary = [];
  List<Station> _stations = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// [silent] is used for the background auto-refresh poll: bundles are now
  /// also auto-created/auto-completed by Start/Stop Tracking on the
  /// Allocation screen, so this list can change without the Supervisor doing
  /// anything here - refresh it live, but without flashing the full spinner.
  Future<void> _load({bool silent = false}) async {
    setState(() {
      if (!silent) _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Always force-refresh here - this screen polls every 6s for genuinely live WIP
      // state, so the normal 15-minute cache would defeat the whole point of polling.
      final results = await Future.wait([
        _apiService.listActive(forceRefresh: true),
        _apiService.getWipSummary(forceRefresh: true),
        _stationApiService.listStations(),
      ]);
      if (!mounted) return;
      setState(() {
        _bundles = results[0] as List<Bundle>;
        _summary = results[1] as List<StationWipSummary>;
        _stations = results[2] as List<Station>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) return;
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _createBundle() async {
    if (_stations.isEmpty) {
      CustomToast.show(context, L10n.of(context).noStationsAvailable, isError: true);
      return;
    }
    await showDialog(
      context: context,
      builder: (_) => CreateBundleDialog(
        stations: _stations,
        onSubmit: (ref, qty, stationId) async {
          await _apiService.createBundle(CreateBundleRequest(bundleRef: ref, quantity: qty, initialStationId: stationId));
        },
      ),
    );
    _load();
  }

  Future<void> _moveBundle(Bundle bundle) async {
    await showDialog(
      context: context,
      builder: (_) => MoveBundleDialog(
        stations: _stations,
        onSubmit: (toStationId) async {
          await _apiService.moveBundle(bundle.id, toStationId);
        },
      ),
    );
    _load();
  }

  Future<void> _completeBundle(Bundle bundle) async {
    try {
      await _apiService.completeBundle(bundle.id);
      if (!mounted) return;
      CustomToast.show(context, "Bundle ${bundle.bundleRef} completed");
      _load();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(L10n.of(context).wipBundleTracking, style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: ThemeTokens.primary,
          unselectedLabelColor: ThemeTokens.textLight,
          indicatorColor: ThemeTokens.primary,
          tabs: [Tab(text: L10n.of(context).activeBundles), Tab(text: L10n.of(context).stationQueues)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "wip_fab",
        onPressed: _isLoading ? null : _createBundle,
        backgroundColor: ThemeTokens.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: L10n.of(context).couldnTLoadWipData,
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
      );
    }
    return TabBarView(
      controller: _tabController,
      children: [
        BundleListView(bundles: _bundles, onRefresh: _load, onMove: _moveBundle, onComplete: _completeBundle),
        StationQueueListView(summary: _summary, onRefresh: _load),
      ],
    );
  }
}
