import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme_tokens.dart';
import 'daily_attendance_screen.dart';
import 'live_attendance_screen.dart';
import 'monthly_attendance_screen.dart';

/// Attendance hub - a menu of tiles that each open a focused sub-screen, so no
/// single screen carries an endless roster scroll.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Text(L10n.of(context).chooseAView, style: ThemeTokens.bodyMedium),
        const SizedBox(height: 20.0),
        _Tile(
          icon: Icons.sensors_rounded,
          title: L10n.of(context).liveAttendance,
          subtitle: L10n.of(context).todaySPunchesPresentAbsent,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiveAttendanceScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.calendar_month_rounded,
          title: L10n.of(context).monthlyAttendance,
          subtitle: L10n.of(context).pickAMonthToReview,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MonthlyAttendanceScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.event_rounded,
          title: L10n.of(context).dailyAttendance,
          subtitle: L10n.of(context).pickAnyPastDateTo,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyAttendanceScreen())),
        ),
        const SizedBox(height: 14.0),
        _Tile(
          icon: Icons.insert_chart_outlined_rounded,
          title: L10n.of(context).reports,
          subtitle: L10n.of(context).exportsAnalytics,
          comingSoon: true,
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  const _Tile({required this.icon, required this.title, required this.subtitle, this.onTap, this.comingSoon = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
        onTap: comingSoon ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: comingSoon ? ThemeTokens.surfaceSunken : ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
            border: Border.all(color: ThemeTokens.hairline),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: comingSoon ? Colors.transparent : ThemeTokens.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                  border: comingSoon ? Border.all(color: ThemeTokens.hairline) : null,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 23, color: comingSoon ? ThemeTokens.textLight : ThemeTokens.primary),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(title, style: ThemeTokens.headingMedium.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis)),
                        if (comingSoon) ...[
                          const SizedBox(width: 8.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                            decoration: BoxDecoration(color: ThemeTokens.warning.withOpacity(0.16), borderRadius: BorderRadius.circular(ThemeTokens.radiusPill)),
                            child: Text("SOON", style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.warning, fontSize: 9)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(subtitle, style: ThemeTokens.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (!comingSoon) const Icon(Icons.chevron_right_rounded, color: ThemeTokens.textLight, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
