import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../components/app_button.dart';
import '../../models/stock_position.dart';
import '../../services/stock_position_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'update_stock_position_dialog.dart';

/// Daily Stock Position across the 7 post-sewing zones (FGS/WSH/IRN-R/QCV/
/// IRN-F/PKG/RTM) - a separate concept from sam_stations (PALMS §22).
class StockPositionScreen extends StatefulWidget {
  const StockPositionScreen({super.key});

  @override
  State<StockPositionScreen> createState() => _StockPositionScreenState();
}

class _StockPositionScreenState extends State<StockPositionScreen> {
  final StockPositionApiService _apiService = StockPositionApiService();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  List<StockPosition> _positions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final positions = await _apiService.listForDate(formatIsoDate(_date), forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _positions = positions;
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

  Future<void> _openUpdateDialog(StockPosition position) async {
    await showDialog(
      context: context,
      builder: (_) => UpdateStockPositionDialog(
        position: position,
        onSubmit: (additions, dispatched) async {
          await _apiService.update(UpdateStockPositionRequest(
            zoneCode: position.zoneCode,
            positionDate: formatIsoDate(_date),
            additions: additions,
            dispatched: dispatched,
          ));
        },
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text(L10n.of(context).dailyStockPosition, style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
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

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    if (_errorMessage != null) {
      return OpsStateMessage(
        icon: Icons.wifi_off_rounded,
        title: L10n.of(context).couldnTLoadStockPosition,
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: L10n.of(context).retry, onPressed: _load)),
      );
    }
    if (_positions.isEmpty) {
      return OpsStateMessage(
        icon: Icons.stacked_line_chart_outlined,
        title: L10n.of(context).noZonesFound,
        body: L10n.of(context).stockZonesHavenTBeen,
      );
    }
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemCount: _positions.length,
        itemBuilder: (context, index) {
          final p = _positions[index];
          return _PositionRow(position: p, onTap: () => _openUpdateDialog(p));
        },
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  final StockPosition position;
  final VoidCallback onTap;
  const _PositionRow({required this.position, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            border: Border.all(color: position.alertTriggered ? ThemeTokens.error.withOpacity(0.5) : ThemeTokens.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(position.zoneName, style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
                    const SizedBox(height: 4.0),
                    Text(
                      "Opening ${position.openingBalance}  ·  +${position.additions}  ·  -${position.dispatched}",
                      style: ThemeTokens.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${position.closingBalance}",
                    style: ThemeTokens.headingLarge.copyWith(fontSize: 20, color: position.alertTriggered ? ThemeTokens.error : ThemeTokens.textPrimary),
                  ),
                  Text("CLOSING", style: ThemeTokens.labelSmall.copyWith(fontSize: 9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
