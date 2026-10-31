import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../components/app_button.dart';
import '../components/factory_kpi_card.dart';
import '../models/factory_kpi_summary.dart';
import '../services/factory_api_service.dart';
import '../utils/theme_tokens.dart';

/// SUPER_ADMIN's Dashboard - cross-factory KPI overview instead of the single-factory
/// dashboard every other role sees, since SUPER_ADMIN belongs to no one factory.
/// Workforce, today's production, today's attendance and month-to-date payroll,
/// one card per factory, so every factory can be compared side by side.
class SuperAdminOverviewScreen extends StatefulWidget {
  const SuperAdminOverviewScreen({super.key});

  @override
  State<SuperAdminOverviewScreen> createState() => _SuperAdminOverviewScreenState();
}

class _SuperAdminOverviewScreenState extends State<SuperAdminOverviewScreen> {
  final FactoryApiService _apiService = FactoryApiService();

  bool _isLoading = true;
  String? _errorMessage;
  List<FactoryKpiSummary> _kpis = [];

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
      final kpis = await _apiService.getKpiOverview(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _kpis = kpis;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: ThemeTokens.error, size: 40),
              const SizedBox(height: 12.0),
              Text(_errorMessage!, style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16.0),
              AppPrimaryButton(label: "Retry", onPressed: _load),
            ],
          ),
        ),
      );
    }
    if (_kpis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text("No factories yet - create one under the Factories tab.", style: ThemeTokens.bodyMedium, textAlign: TextAlign.center),
        ),
      );
    }

    final totalEmployees = _kpis.fold<int>(0, (sum, k) => sum + k.totalEmployees);
    final totalPieces = _kpis.fold<int>(0, (sum, k) => sum + k.todayProductionPieces);
    final totalPayroll = _kpis.fold<double>(0, (sum, k) => sum + k.monthToDatePayroll);

    return RefreshIndicator(
      color: ThemeTokens.primary,
      onRefresh: () => _load(forceRefresh: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              gradient: ThemeTokens.primaryGradient,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            ),
            child: Row(
              children: [
                _overallStat("Factories", "${_kpis.length}"),
                _overallStat("Total Employees", "$totalEmployees"),
                _overallStat("Today's Pieces", "$totalPieces"),
                _overallStat("MTD Payroll", "₹${totalPayroll.toStringAsFixed(0)}"),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          if (_kpis.length > 1) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              decoration: BoxDecoration(
                color: ThemeTokens.surfaceSolid,
                borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                border: Border.all(color: ThemeTokens.hairline),
                boxShadow: ThemeTokens.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EMPLOYEES BY FACTORY", style: ThemeTokens.labelSmall),
                  const SizedBox(height: 16.0),
                  SizedBox(height: 160, child: _employeesBarChart()),
                  const SizedBox(height: 4.0),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
          ],
          Text("BY FACTORY", style: ThemeTokens.labelSmall),
          const SizedBox(height: 12.0),
          ..._kpis.map((kpi) => Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: FactoryKpiCard(kpi: kpi),
              )),
        ],
      ),
    );
  }

  Widget _employeesBarChart() {
    final maxValue = _kpis.map((k) => k.totalEmployees).fold<int>(0, (a, b) => a > b ? a : b);
    final double gridInterval = maxValue == 0 ? 1.0 : (maxValue / 4).ceilToDouble().clamp(1.0, double.infinity);

    return BarChart(
      BarChartData(
        maxY: maxValue == 0 ? 1.0 : maxValue * 1.2,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: gridInterval,
          getDrawingHorizontalLine: (_) => FlLine(color: ThemeTokens.hairline, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: gridInterval,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: ThemeTokens.caption.copyWith(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _kpis.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(_kpis[index].factoryCode, style: ThemeTokens.caption.copyWith(fontSize: 10), overflow: TextOverflow.ellipsis),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(_kpis.length, (index) {
          final kpi = _kpis[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: kpi.totalEmployees.toDouble(),
                color: ThemeTokens.primary,
                width: 28,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _overallStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: ThemeTokens.headingLarge.copyWith(fontSize: 18, color: Colors.white), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2.0),
          Text(label, style: ThemeTokens.caption.copyWith(color: Colors.white.withValues(alpha: 0.85)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
