import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/factory_kpi_summary.dart';
import '../utils/theme_tokens.dart';

/// One factory's KPI card for the SUPER_ADMIN overview - workforce, today's
/// production, today's attendance and month-to-date payroll. Two donut charts
/// (workforce active/inactive, today's attendance present/absent) plus headline
/// numbers and a payroll footer.
class FactoryKpiCard extends StatelessWidget {
  final FactoryKpiSummary kpi;

  const FactoryKpiCard({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceSolid,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        border: Border.all(color: ThemeTokens.hairline),
        boxShadow: ThemeTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ThemeTokens.background,
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
                  border: Border.all(color: ThemeTokens.hairline),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.factory_rounded, size: 18, color: kpi.active ? ThemeTokens.primary : ThemeTokens.textLight),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kpi.factoryName, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2.0),
                    Text(kpi.factoryCode, style: ThemeTokens.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18.0),
          Row(
            children: [
              _stat("Employees", "${kpi.totalEmployees}", ThemeTokens.primary),
              _stat("Stations", "${kpi.stationCount}", ThemeTokens.primary),
              _stat("Today's Pieces", "${kpi.todayProductionPieces}", ThemeTokens.success),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              Expanded(
                child: _donut(
                  title: "Workforce",
                  present: kpi.activeEmployees,
                  total: kpi.totalEmployees,
                  presentLabel: "Active",
                  absentLabel: "Inactive",
                  color: ThemeTokens.success,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: _donut(
                  title: "Attendance",
                  present: kpi.todayAttendancePresent,
                  total: kpi.todayAttendanceTotal,
                  presentLabel: "Present",
                  absentLabel: "Absent",
                  color: ThemeTokens.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: ThemeTokens.background,
              borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(Icons.payments_outlined, size: 16, color: ThemeTokens.textSecondary),
                const SizedBox(width: 8.0),
                Text("Month-to-date payroll", style: ThemeTokens.caption),
                const Spacer(),
                Text(
                  "₹${kpi.monthToDatePayroll.toStringAsFixed(2)}",
                  style: ThemeTokens.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: ThemeTokens.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: ThemeTokens.headingLarge.copyWith(fontSize: 20, color: color)),
          const SizedBox(height: 2.0),
          Text(label, style: ThemeTokens.caption, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _donut({
    required String title,
    required int present,
    required int total,
    required String presentLabel,
    required String absentLabel,
    required Color color,
  }) {
    final absent = (total - present).clamp(0, total);
    final hasData = total > 0;
    final pct = hasData ? (present / total * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: ThemeTokens.labelSmall.copyWith(fontSize: 10)),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 26,
                  startDegreeOffset: -90,
                  sections: hasData
                      ? [
                          PieChartSectionData(value: present.toDouble(), color: color, radius: 16, showTitle: false),
                          PieChartSectionData(value: absent.toDouble(), color: ThemeTokens.hairline, radius: 16, showTitle: false),
                        ]
                      : [
                          PieChartSectionData(value: 1, color: ThemeTokens.hairline, radius: 16, showTitle: false),
                        ],
                ),
              ),
              Text(
                hasData ? "$pct%" : "—",
                style: ThemeTokens.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: ThemeTokens.textPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        _legendDot(color, "$presentLabel ($present)"),
        const SizedBox(height: 3.0),
        _legendDot(ThemeTokens.hairlineStrong, "$absentLabel (${hasData ? absent : 0})"),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6.0),
        Flexible(child: Text(label, style: ThemeTokens.caption.copyWith(fontSize: 11), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
