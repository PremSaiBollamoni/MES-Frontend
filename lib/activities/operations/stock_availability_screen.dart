import 'package:flutter/material.dart';
import '../../components/app_button.dart';
import '../../components/custom_toast.dart';
import '../../models/stock_availability.dart';
import '../../services/stock_availability_api_service.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'stock_availability_row.dart';
import 'stock_quantity_dialog.dart';

/// Pre-shift per-station stock check: Supervisor logs the current quantity
/// on hand and AVAILABLE/NO_STOCK is auto-derived against the station's
/// configured minimum threshold (PALMS stock-availability rework).
class StockAvailabilityScreen extends StatefulWidget {
  const StockAvailabilityScreen({super.key});

  @override
  State<StockAvailabilityScreen> createState() => _StockAvailabilityScreenState();
}

class _StockAvailabilityScreenState extends State<StockAvailabilityScreen> {
  final StockAvailabilityApiService _apiService = StockAvailabilityApiService();

  DateTime _date = DateTime.now();
  bool _isLoading = true;
  String? _errorMessage;
  List<StockAvailability> _items = [];
  final Set<int> _updating = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _apiService.listForDate(formatIsoDate(_date));
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _logStock(StockAvailability item) async {
    final qty = await showStockQuantityDialog(
      context,
      stationLabel: "${item.stationNumber} · ${item.operationName}",
      initialValue: item.currentStockQty,
    );
    if (qty == null) return;

    setState(() => _updating.add(item.stationId));
    try {
      await _apiService.log(LogStockAvailabilityRequest(
        stationId: item.stationId,
        shiftDate: formatIsoDate(_date),
        currentStockQty: qty,
        reason: null,
      ));
      await _load();
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _updating.remove(item.stationId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(title: Text("Stock Availability", style: ThemeTokens.headingMedium.copyWith(fontSize: 17))),
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
        title: "Couldn't load stock availability",
        body: _errorMessage!,
        action: SizedBox(width: 180, child: AppPrimaryButton(label: "Retry", onPressed: _load)),
      );
    }
    if (_items.isEmpty) {
      return const OpsStateMessage(
        icon: Icons.inventory_2_outlined,
        title: "No stations found",
        body: "Set up stations first, then check back here.",
      );
    }
    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isUpdating = _updating.contains(item.stationId);
          return StockAvailabilityRow(item: item, isUpdating: isUpdating, onTap: () => _logStock(item));
        },
      ),
    );
  }
}
