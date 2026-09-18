import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/report.dart';
import '../utils/theme_tokens.dart';
import 'reports/report_type_screen.dart';

class _ReportTypeCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final ReportType type;
  final String emptyTitle;
  final String emptyBody;
  final String filenamePrefix;

  /// Whether this report can be generated for either a single day or a whole month
  /// (shows a Daily/Monthly toggle) - currently only Attendance.
  final bool supportsMonthly;

  /// Whether this report is ALWAYS monthly, with no daily mode at all - currently only Earnings.
  final bool alwaysMonthly;

  const _ReportTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.emptyTitle,
    required this.emptyBody,
    required this.filenamePrefix,
    this.supportsMonthly = false,
    this.alwaysMonthly = false,
  });
}

const _reportTypeCards = [
  _ReportTypeCard(
    title: "AI Production Report",
    subtitle: "Overall production, efficiency, targets and bottlenecks",
    icon: Icons.precision_manufacturing_rounded,
    type: ReportType.production,
    emptyTitle: "No reports yet",
    emptyBody: "Generate your first daily production report using the button above.",
    filenamePrefix: "production_report",
  ),
  _ReportTypeCard(
    title: "Station-wise Stock Report",
    subtitle: "Stock status, shortages and daily position by station/zone",
    icon: Icons.inventory_2_rounded,
    type: ReportType.stock,
    emptyTitle: "No reports yet",
    emptyBody: "Generate your first station-wise stock report using the button above.",
    filenamePrefix: "stock_report",
  ),
  _ReportTypeCard(
    title: "Attendance Report",
    subtitle: "Daily or monthly attendance register, lateness and manning gaps",
    icon: Icons.fingerprint_rounded,
    type: ReportType.attendance,
    emptyTitle: "No reports yet",
    emptyBody: "Generate your first attendance report using the button above.",
    filenamePrefix: "attendance_report",
    supportsMonthly: true,
  ),
  _ReportTypeCard(
    title: "Worker Performance Report",
    subtitle: "Full worker ranking, top/lowest performers and recommendations",
    icon: Icons.leaderboard_rounded,
    type: ReportType.workerPerformance,
    emptyTitle: "No reports yet",
    emptyBody: "Generate your first worker performance report using the button above.",
    filenamePrefix: "worker_performance_report",
  ),
  _ReportTypeCard(
    title: "Monthly Earnings Report",
    subtitle: "Top/low earners and the lowest-earning stations for a month",
    icon: Icons.payments_rounded,
    type: ReportType.earnings,
    emptyTitle: "No reports yet",
    emptyBody: "Generate your first monthly earnings report using the button above.",
    filenamePrefix: "monthly_earnings_report",
    alwaysMonthly: true,
  ),
];

/// Hub screen listing every AI-generated report type; each card opens its own
/// ReportTypeScreen (date picker, generate, previous reports for that type only).
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Text(L10n.of(context).aiReports, style: ThemeTokens.headingLarge.copyWith(fontSize: 24)),
            const SizedBox(height: 4.0),
            Text(L10n.of(context).claudeGeneratedAnalyticsReportsExported, style: ThemeTokens.bodyMedium),
            const SizedBox(height: 20.0),
            ..._reportTypeCards.map((card) => _ReportCardTile(
                  card: card,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportTypeScreen(
                        reportType: card.type,
                        title: card.title,
                        emptyTitle: card.emptyTitle,
                        emptyBody: card.emptyBody,
                        filenamePrefix: card.filenamePrefix,
                        supportsMonthly: card.supportsMonthly,
                        alwaysMonthly: card.alwaysMonthly,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ReportCardTile extends StatelessWidget {
  final _ReportTypeCard card;
  final VoidCallback onTap;

  const _ReportCardTile({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14.0),
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: ThemeTokens.surfaceSolid,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(color: ThemeTokens.hairline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: ThemeTokens.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
              ),
              child: Icon(card.icon, color: ThemeTokens.primary, size: 22),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.title, style: ThemeTokens.bodyLarge.copyWith(fontSize: 15)),
                  const SizedBox(height: 4.0),
                  Text(card.subtitle, style: ThemeTokens.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight),
          ],
        ),
      ),
    );
  }
}
