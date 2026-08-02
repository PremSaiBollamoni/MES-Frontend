import 'package:flutter/material.dart';
import '../../utils/employee_names.dart';
import '../../utils/operation_names.dart';
import '../../l10n/app_localizations.dart';
import '../../models/employee_day_activity.dart';
import '../../models/production_entry.dart';
import '../../models/tracking_session.dart';
import '../../utils/theme_tokens.dart';
import 'operations_widgets.dart';
import 'production_entry_detail_dialog.dart';
import 'tracking_session_screen.dart';

/// Full-day activity for a single employee: their in-progress tracking
/// session (if any) followed by every completed production entry they
/// logged that day, since one employee can have several entries per day
/// (one per station worked).
class EmployeeDayDetailScreen extends StatelessWidget {
  final EmployeeDayActivity activity;
  final DateTime date;

  const EmployeeDayDetailScreen({super.key, required this.activity, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text(EmployeeNames.display(context, activity.employeeName), style: ThemeTokens.headingMedium.copyWith(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Text(formatLongDate(date), style: ThemeTokens.caption),
          const SizedBox(height: 16.0),
          if (activity.activeSession != null)
            _InProgressCard(
              session: activity.activeSession!,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TrackingSessionScreen(session: activity.activeSession!)),
              ),
            ),
          if (activity.entries.isEmpty && activity.activeSession == null)
            OpsStateMessage(
              icon: Icons.speed_outlined,
              title: L10n.of(context).noActivityForThisDay,
              body: L10n.of(context).thisEmployeeHasNoLogged,
            ),
          for (final entry in activity.entries)
            _EntryRow(entry: entry, onTap: () => showProductionEntryDetailDialog(context, entry)),
        ],
      ),
    );
  }
}

class _InProgressCard extends StatelessWidget {
  final TrackingSession session;
  final VoidCallback onTap;
  const _InProgressCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: ThemeTokens.warning.withOpacity(0.06),
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            border: Border.all(color: ThemeTokens.warning.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${session.stationNumber} · ${OperationNames.display(context, session.operationName)}", style: ThemeTokens.headingMedium.copyWith(fontSize: 15)),
                    const SizedBox(height: 4.0),
                    Text("${session.piecesIssued} pcs issued", style: ThemeTokens.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: ThemeTokens.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(ThemeTokens.radiusPill),
                ),
                child: Text(L10n.of(context).inProgress, style: ThemeTokens.labelSmall.copyWith(color: ThemeTokens.warning, fontSize: 9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final ProductionEntry entry;
  final VoidCallback onTap;
  const _EntryRow({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = classificationColor(entry.classification);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            border: Border.all(color: ThemeTokens.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${entry.stationNumber} · ${OperationNames.display(context, entry.operationName)}", style: ThemeTokens.headingMedium.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4.0),
                    Text("${entry.piecesProduced} pcs", style: ThemeTokens.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${entry.efficiencyPct.toStringAsFixed(0)}%", style: ThemeTokens.headingMedium.copyWith(fontSize: 16, color: color)),
                  Text(entry.classification, style: ThemeTokens.labelSmall.copyWith(color: color, fontSize: 9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
